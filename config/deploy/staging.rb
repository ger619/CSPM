server "172.16.2.15", user: "taskbridgetest", roles: %w{app db web}

set :rails_env, "staging"
set :branch, "dev"  # Or whatever branch you deploy to staging
