#!/bin/sh

echo "input your username"

read -p "username:" a

echo "input your secret"

read -p "password:" b

if [ ` awk '{print $1}' /etc/ppp/chap-secrets |grep "li"|wc -l` -eq 0 ];then

echo "$a      pptpd      $b     *" >>/etc/ppp/chap-secrets

fi
