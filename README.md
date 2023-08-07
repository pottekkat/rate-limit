# Rate Limit Your APIs With Apache APISIX

This repository contains the complete configuration files and instructions to deploy for the article [Rate Limit Your APIs With Apache APISIX](http://navendu.me/posts/rate-limit/).

## Instructions

To run everything:

```shell
docker compose up
```

> [!IMPORTANT]
> The etcd image used in this example is for ARM. Please change the image if needed.

You can then find the Admin API calls in `apisix/admin_api_config.sh`.
