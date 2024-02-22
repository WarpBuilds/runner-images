# we need to execute all post-gen steps for the final vm
# refer to images/ubuntu/assets/post-gen/

# for now the environment-variables.sh script is only run.
touch /runner/.env
sh -c 'grep "^PATH=" /etc/environment | head -n 1 >> /runner/.env'
sed -i "s|\$HOME|/home/runner|g" /runner/.env

UserId=$(grep '^runner:' /etc/passwd | cut -d: -f3)
loginctl enable-linger $UserId

systemctl stop --now docker.service
touch /etc/docker/daemon.json
echo '{"registry-mirrors": ["https://mirror.warpbuild.com"]}' > /etc/docker/daemon.json
systemctl start --now docker.service
