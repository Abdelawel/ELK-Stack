#!/bin/bash
echo "Generating Nginx traffic..."
for i in {1..20}; do
  curl -s http://localhost/ > /dev/null
  curl -s http://localhost/notfound > /dev/null
done
echo "Traffic generated."

echo "Exporting sample_nginx_2.log deliverable..."
tail -n 50 /var/log/nginx/access.log > /vagrant/linux-vm/sample_nginx_2.log
echo "Deliverable sample_nginx_2.log successfully created in your workspace!"
