#!/bin/sh

ENABLE_TWEET_DELETE=${ENABLE_TWEET_DELETE:-0}
ENABLE_TWEET_UNFAV=${ENABLE_TWEET_UNFAV:-0}

if [ -z ${TWITTER_CONSUMER_KEY} ]; then 
  echo "TWITTER_CONSUMER_KEY is required."
fi
if [ -z ${TWITTER_CONSUMER_SECRET} ]; then 
  echo "TWITTER_CONSUMER_SECRET is required."
fi
if [ -z ${TWITTER_OAUTH_TOKEN} ]; then 
  echo "TWITTER_OAUTH_TOKEN is required."
fi
if [ -z ${TWITTER_OAUTH_TOKEN_SECRET} ]; then 
  echo "TWITTER_CONSUMER_TOKEN_SECRET is required."
fi

if [ ${ENABLE_TWEET_DELETE} -ne 0 ]; then
  echo "Tweet Deletion is enabled. Executing."
  ruby /app/delete.rb
fi

if [ ${ENABLE_TWEET_UNFAV} -ne 0 ]; then
  echo "Tweet Unfavouriting is enabled. Executing."
  ruby /app/unfav.rb
fi
