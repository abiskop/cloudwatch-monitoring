cloudwatch-monitoring
=====================

Install Amazon AWS Cloud Watch Monitoring Scripts


Defaults:

```ruby
default["cw_mon"]["user"]              = "ubuntu"
default["cw_mon"]["group"]             = "ubuntu"
default["cw_mon"]["home_dir"]          = "/home/ubuntu"
default["cw_mon"]["version"]           = "1.1.0"
default["cw_mon"]["release_url"]       = "http://ec2-downloads.s3.amazonaws.com/cloudwatch-samples/CloudWatchMonitoringScripts-v1.1.0.zip"
default["cw_mon"]["aws_access_mode"]   = "key"
default["cw_mon"]["aws_iam_role"]      = "some-iam-role"
default["cw_mon"]["aws_access_key"]    = "<insert access key>"
default["cw_mon"]["aws_secret_key"]    = "<insert secret access key>"
default["cw_mon"]["disk_path"]         = "/"
default["cw_mon"]["cron_minutes"]      = "*/5"
default["cw_mon"]["metrics"] = [
  "mem-util",
  "mem-used",
  "mem-avail",
  "swap-util",
  "swap-used",
  "disk-space-util",
  "disk-space-used",
  "disk-space-avail"
]
```