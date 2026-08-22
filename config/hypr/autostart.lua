-- Extra autostart processes.
-- o.launch_on_start("my-service")

-- EasyEffects speaker EQ (MBP 16 M1 preset, set default by
-- bin/setup-easyeffects). --service-mode runs the PipeWire filter chain
-- without opening a window (--gapplication-service is the same thing but
-- deprecated as of this EasyEffects version).
o.launch_on_start("easyeffects --service-mode")
