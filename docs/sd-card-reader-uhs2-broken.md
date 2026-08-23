# Built-in SD card reader hangs on data reads (UHS-II)

**Hardware:** MacBook Pro 16" M1 (j316), built-in SD slot —
`02:00.0 SD Host controller: Genesys Logic, Inc GL9755 SD Host Controller (rev 01)`
**Kernel:** 7.1.6-1-1-ARCH (Asahi), `sdhci` / `sdhci_pci` / `sdhci_uhs2` / `cqhci`
**Card tested:** Sony-formatted UHS-II SD, 116.6 GB, name field `LX128`
**Found:** 2026-08-22, culling RAWs in geeqie

## Symptom

Directory listings work fine — `ls`/`find` enumerated 4910 files with no trouble.
**Bulk data reads hang.** Reading a single 24 MB `.ARW` never completed; a 4 MB
read with `iflag=direct` (cache bypassed) on an untouched file did not return
within 60s and left `dd` wedged in uninterruptible (D) state.

Beware a misleading measurement: re-reading a file that was partly pulled in
before gives 3–4 GB/s. That is the page cache, not the card. Always test with
`iflag=direct` on a file that has not been touched.

Any application that touches the card appears to freeze. This looked like a
geeqie problem at first; geeqie is only the messenger.

`journalctl -k` shows a continuous stream, roughly one every 10 seconds — each
one a 10-second stall:

```
mmc0: Timeout waiting for hardware interrupt.
mmc0: Timeout waiting for hardware cmd interrupt.
```

followed by an SDHCI register dump that includes an `sdhci_uhs2:` section,
i.e. the failure is on the UHS-II path.

## Cause

UHS-II support for the GL9755 is a recent and still-maturing part of the MMC
subsystem — it went through ~23 patch revisions upstream, several specifically
about *increasing the timeout before detecting the UHS-II interface* and about
clock/reset/interrupt handling on UHS-II. The card here is UHS-II, so it
negotiates into exactly that path. Command/metadata traffic survives; the data
path does not.

## No clean software workaround

- **Cannot blacklist `sdhci_uhs2`.** `sdhci_pci` hard-depends on it
  (`modinfo sdhci_pci` → `depends: sdhci,mmc_core,cqhci,sdhci-uhs2`), so
  blacklisting takes the whole reader offline rather than falling back to
  UHS-I.
- **No module parameter forces UHS-I.** `sdhci` exposes only `debug_quirks`
  and `debug_quirks2` bitmasks, and there is no UHS-II-disable quirk among
  them. `sdhci_pci` exposes no parameters at all.

## Workaround: use a USB-C card reader

This is the fix in practice. A USB reader enumerates as USB mass storage and
goes through `usb-storage` — it never touches `sdhci`/`sdhci_uhs2`/GL9755, so
the broken code path is bypassed entirely. Confirmed to be the better route.

The card itself is fine — it works in the camera, and these are controller-side
timeouts, not media errors.

## Retry later

Recheck the built-in slot after kernel updates; this is an actively-developed
area upstream and may simply start working. Test with:

```bash
FRESH=$(find /run/media/$USER/<label>/DCIM -name '*.ARW' | tail -1)
timeout 60 dd if="$FRESH" of=/dev/null bs=1M count=4 iflag=direct
journalctl -k -n 200 | grep -c 'Timeout waiting for hardware'
```

A completed read plus a zero timeout count means it is fixed.

## Gotcha: ejecting the USB reader latches it STOPPED, and replugging won't fix it

Hit 2026-08-22, right after switching to the USB-C reader. Symptom looks like
dead hardware:

- reader enumerates fine (`usb-storage`, `scsi host0`, both LUNs attach)
- **but no usable block device** — `sda`/`sdb` present at **0B**, or missing
  entirely
- `usb 2-1: reset SuperSpeed USB device number 2` every ~30s (each one a
  command timing out), then it gives up
- `sd 0:0:0:0: [sda] Read Capacity(10) failed` / `0 512-byte logical blocks`
- reproduces with **different cards**, in **different ports**, and survives
  reseating and replugging

Cause: a prior eject (file-manager "safely remove" / `udisksctl power-off`)
sends SCSI `START STOP UNIT` with the stop bit. This reader **latches** that
state and stays stopped across unplug/replug. It never gets far enough to look
at the card at all — which is why every card behaves identically.

Tell-tale: even `sg_inq` (plain INQUIRY, which doesn't touch the media) hangs.
A card fault would let INQUIRY succeed and fail later at READ CAPACITY; only a
wedged reader fails this early.

### Fix

```bash
sudo sg_start --start /dev/sg0     # needs sg3_utils; /dev/sg* is root:disk
```

Then it comes straight back — verified `Read Capacity: blocks=244512768`
(116.6 GB) immediately after, automounted by udiskie, and reading at
**90 MB/s** on an uncached `iflag=direct` read (vs the internal slot, which
hangs entirely).

Use `sudo sg_turs /dev/sg0` to check state first: a stopped/empty unit reports
`device not ready`. Note the reader exposes **two** LUNs (SD + microSD), so the
unused slot legitimately reports `device not ready` — don't read that as a
fault.

**Avoid the whole problem** by unplugging the reader rather than using
"eject"/"safely remove" on it. The card is FAT and mounted `sync`-ish by
udiskie; just make sure no transfer is running first.

## Related: geeqie stalls over the network share too

Separate problem, same appearance. geeqie fully decodes each ~25 MB RAW to
render a preview; over the ~7 MB/s sshfs link to the desktop that is ~3.5 s per
image, blocking the UI. Fix is in geeqie's **Preferences → Thumbnails**: enable
**embedded/EXIF thumbnails** and **thumbnail caching**, so it reads the small
JPEG preview baked into each ARW instead of the whole file. Note geeqie only
writes `~/.config/geeqie/geeqierc.xml` on clean exit, so a running instance is
on defaults until it is closed properly.
