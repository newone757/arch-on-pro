-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- EasyEffects speaker EQ (MBP 16 M1 preset, set default by
-- bin/setup-easyeffects). --service-mode runs the PipeWire filter chain
-- (--gapplication-service is the same thing but deprecated); --hide-window
-- is the separate flag that actually suppresses the GUI window.
o.launch_on_start("easyeffects --service-mode --hide-window")
