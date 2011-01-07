# 0.1.0
* Added ruby 1.8 compatibility.

# 0.0.2
* Configuration is managed by the Configurator class.
* Added the ability to over-ride the endpoint in non-production environments.
* By default, only send statistics to papermill in production mode.
  This can be changed for any environment by setting the `live_mode: true`.
* Request timeout is now configurable on a per-environment basis.
* Only gather environment headers for specific keys.

# 0.0.1
* change 'api_key' param to 'token'
