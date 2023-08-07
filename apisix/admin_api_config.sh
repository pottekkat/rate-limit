#!/bin/bash

# Create a global rule
curl localhost:9180/apisix/admin/global_rules/rate_limit_all -X PUT -d '
{
  "plugins": {
    "limit-req": {
      "rate": 30,
      "burst": 30,
      "key_type": "var",
      "key": "remote_addr",
      "rejected_code": 429,
      "rejected_msg": "rate limit exceeded!"
    }
  }
}'

# Configure rate limit on a route
curl localhost:9180/apisix/admin/routes/rate_limit_route -X PUT -d '
{
  "uri": "/api",
  "upstream": {
    "type": "roundrobin",
    "nodes": {
      "upstream:80": 1
    }
  },
  "plugins": {
    "limit-count": {
      "count": 10,
      "time_window": 60,
      "key_type": "var",
      "key": "remote_addr",
      "policy": "local",
      "rejected_code": 429,
      "rejected_msg": "rate limit exceeded!"
    }
  }
}'

# Test the created route
for i in {1..15}; do
  curl localhost:9080/api
done

# Set up rate limit on a consumer
curl localhost:9180/apisix/admin/consumers -X PUT -d '
{
  "username": "alice",
  "plugins": {
    "key-auth": {
      "key": "beautifulalice"
    },
    "limit-conn": {
      "conn": 5,
      "burst": 3,
      "default_conn_delay": 0.1,
      "key_type": "var",
      "key": "remote_addr",
      "rejected_code": 429,
      "rejected_msg": "too many concurrent requests!"
    }
  }
}'

# Set up rate limits on a consumer group
curl localhost:9180/apisix/admin/consumer_groups/team_acme -X PUT -d '
{
  "plugins": {
    "limit-count": {
      "count": 10,
      "time_window": 60,
      "key_type": "var",
      "key": "remote_addr",
      "policy": "local",
      "rejected_code": 429,
      "group": "team_acme"
    }
  }
}'

# Use Redis to store the counter
curl localhost:9180/apisix/admin/consumer_groups/team_edward -X PUT -d '
{
  "plugins": {
    "limit-count": {
      "count": 10,
      "time_window": 60,
      "key_type": "var",
      "key": "remote_addr",
      "policy": "redis",
      "redis_host": "redis",
      "redis_port": 6379,
      "redis_password": "password",
      "redis_database": 1,
      "redis_timeout": 1001,
      "rejected_code": 429,
      "group": "team_edward"
    }
  }
}'
