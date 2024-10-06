# hostCPU defaults to the current CPU and can be overridden with `--cpu:<target>`, see `nim targets`
switch("path", "arch/common")
switch("path", "arch/" & config["arch"])

echo "path: ", "arch/" & config["arch"]
