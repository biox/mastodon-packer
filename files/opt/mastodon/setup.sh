#!/bin/bash

echo "Booting Mastodon's first-time setup wizard..." &&
  su - mastodon -c "cd /home/mastodon/live && RAILS_ENV=production /home/mastodon/.rbenv/shims/bundle exec rake digitalocean:setup" &&
  export $(grep '^LOCAL_DOMAIN=' /home/mastodon/live/.env.production | xargs) &&
  echo "Launching Let's Encrypt utility to obtain SSL certificate..." &&
  systemctl stop nginx &&
  certbot certonly --standalone --agree-tos -d $LOCAL_DOMAIN &&
  cp /home/mastodon/live/dist/nginx.conf /etc/nginx/sites-available/mastodon &&
  sed -i -- "s/example.com/$LOCAL_DOMAIN/g" /etc/nginx/sites-available/mastodon &&
  ln -sfn /etc/nginx/sites-available/mastodon /etc/nginx/sites-enabled/mastodon &&
  sed -i -- "s/  # ssl_certificate/  ssl_certificate/" /etc/nginx/sites-available/mastodon &&
  systemctl start nginx &&
  systemctl enable mastodon-web && systemctl start mastodon-web &&
  systemctl enable mastodon-streaming && systemctl start mastodon-streaming &&
  systemctl enable mastodon-sidekiq && systemctl start mastodon-sidekiq &&
  cp -f /etc/skel/.bashrc /root/.bashrc &&
  rm /home/mastodon/live/lib/tasks/digital_ocean.rake &&
  echo "Setup is complete! Login at https://$LOCAL_DOMAIN"
