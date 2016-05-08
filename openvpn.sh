mkdir /dev/net; mknod /dev/net/tun c 10 200
echo 'net.ipv4.ip_forward=1' >/etc/sysctl.conf
sysctl -p
apt-get update
apt-get -y install iptables openvpn openssl lzop git curl gcc wget
cp -r /usr/share/easy-rsa/ /etc/openvpn/
cd /etc/openvpn/easy-rsa/2.0ource vars
./clean-all
./build-ca
./build-key-server server
./build-key client
./build-dh
myip=`wget -O - http://ipecho.net/plain`
iptables -t nat -A POSTROUTING -s 192.66.0.0/16 -j SNAT --to-source $myip
cd /etc/openvpn/
echo '开始编译mproxy'
git clone https://github.com/2422494482/mproxy.git
gcc -o ./mp ./mproxy/mproxy.c
echo
echo 
echo "写入配置文件"
echo "
local 0.0.0.0
port 443
proto tcp
dev tun
ca /etc/openvpn/easy-rsa/2.0/keys/ca.crt
cert /etc/openvpn/easy-rsa/2.0/keys/server.crt
key /etc/openvpn/easy-rsa/2.0/keys/server.key
dh /etc/openvpn/easy-rsa/2.0/keys/dh1024.pem
ifconfig-pool-persist ipp.txt
server 192.66.1.0 255.255.255.0
push \"redirect-gateway\"
push \"dhcp-option DNS 114.114.114.114\"
push \"dhcp-option DNS 114.114.115.115\"
client-to-client
script-security 3 system
auth-user-pass-verify /etc/openvpn/login.sh via-env
client-disconnect /etc/openvpn/logout.sh
duplicate-cn
keepalive 20 60
comp-lzo
max-clients 50
persist-key
persist-tun
status openvpn-status.log
log-append openvpn.log
verb 3
mute 20
">server.conf
echo "配置文件制作完毕"
echo
sleep 3
clear
cp ./mproxy/login.sh ./login.sh
cp ./mproxy/logout.sh ./logout.sh
chmod u+x ./*.sh ./mp
echo '正在启动vpn'
service openvpn restart
echo '正在启动mproxy'
./mp -d

## ovpn生成
echo 
echo "正在生成移动线路.ovpn配置文件..."
echo "
# 本文件由系统自动生成
client
dev tun
proto tcp
remote wap.10086.cn 80
########免流代码########
http-proxy-option EXT1 \"openvpn 127.0.0.1:443\"
http-proxy-option EXT1 \"X-Online-Host: wap.10086.cn\" 
http-proxy-option EXT1 \"Host: wap.10086.cn\"
http-proxy $myip 8080
########免流代码########
resolv-retry infinite
nobind
persist-key
persist-tun
auth-user-pass
ns-cert-type server
redirect-gateway
keepalive 20 60
comp-lzo
verb 3
mute 20
route-method exe
route-delay 2
## 证书
<ca>
`cat ./easy-rsa/2.0/keys/ca.crt`
</ca>
<cert>
`cat ./easy-rsa/2.0/keys/client.crt`
</cert>
<key>
`cat ./easy-rsa/2.0/keys/client.key`
</key>
" >ovpn.ovpn
echo "配置文件制作完毕"
echo "正在创建下载链接：" echo '=========================================================================='
echo 
echo "上传文件："
curl --upload-file ./ovpn.ovpn https://transfer.sh/openvpn.ovpn
echo 
echo "上传成功"
echo "请复制“https://transfer.sh/..”链接到浏览器OpenVPN成品配置文件"
echo 
echo '正在设置Cron重启脚本'
echo '59 23 * * * root service openvpn soft-restart' >>/etc/crontab
echo '=========================================================================='
echo 您的IP是：$myip
