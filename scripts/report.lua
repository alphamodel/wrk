json = require "json"

function setup(thread)
  thread0 = thread0 or thread
end

function init(args)
  file = args[1] or "/dev/null"
end

function done(summary, latency, requests)
  file = io.open(thread0:get("file"), "w")

  percentiles = {}
  rpercentiles = {}

  for _, p in pairs({ 25, 50, 75, 90, 99, 99.999 }) do
    k = string.format("%g%%", p)
    v = latency:percentile(p)
    percentiles[k] = v/1000
    v = requests:percentile(p)
    rpercentiles[k] = v
  end

  file:write(json.encode({
    duration_s = summary.duration/1000/1000,
    total_requests = summary.requests,
    quantile_requests = rpercentiles,
    bytes    = summary.bytes,
    errors   = summary.errors,
    latency_ms  = {
      min         = latency.min/1000,
      max         = latency.max/1000,
      mean        = latency.mean/1000,
      stdev       = latency.stdev/1000,
      percentiles = percentiles,
    },
  }))
  file:close()
end
