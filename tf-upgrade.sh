#!/bin/bash

url="https://releases.hashicorp.com/terraform"
# Grab the last 10 options for terraform
options=( $(curl -sL https://releases.hashicorp.com/terraform/index.json \
          | jq -r '.versions[].builds[].url' \
          | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | egrep -v 'rc|beta' \
          | egrep 'linux.*amd64' | tail -10 | grep terraform \
          | cut -d '_' -f 2 | cut -d '<' -f 1) )
bin="/usr/local/bin/terraform"


current_version=`${bin} version | head -1 | cut -d 'v' -f 2`
echo "Your current version is ${current_version}"

select opt in "${options[@]}" "Quit" ; do
  if (( REPLY == 1 + ${#options[@]} )) ; then
    exit
    elif [ ! -f "${bin}" ]; then
    echo "Installing Terraform v${latest_version}"
    latest_version=( $(curl -sL https://releases.hashicorp.com/terraform/index.json \
                    | jq -r '.versions[].builds[].url' | sort -V | egrep -v 'rc|alpha|beta' \
                    | egrep 'linux.*amd64' | tail -n1 | grep terraform \
                    | cut -d '_' -f 2 | cut -d '<' -f 1) )
    cd /tmp && \
    /bin/wget -q ${url}/${latest_version}/terraform_${latest_version}_linux_amd64.zip && \
    /bin/unzip -qq terraform_${latest_version}_linux_amd64.zip
    sudo cp terraform ${bin}
    exit
  elif (( REPLY > 0 && REPLY <= ${#options[@]} )) ; then
    echo "Select a version higher than your current version."
    if [ "${current_version}" = "`echo -e "${current_version}\n${opt}" | sort -V | head -n1`" ]; then
      echo -n "Do you want to install this new release ${opt} (y/n)? "
      read answer
      if [ "$answer" != "${answer#[Yy]*}" ]; then
        cd /tmp && \
        /usr/bin/wget -q ${url}/${opt}/terraform_${opt}_linux_amd64.zip && \
        /usr/bin/unzip -qq terraform_${opt}_linux_amd64.zip
        sudo cp terraform ${bin} && sudo cp terraform ${bin}-${opt}
        echo "Terraform updated to the ${opt} release"
        exit
      else
        echo "Skipped the Terraform update to v${opt} release"
        exit
      fi
    fi
  else
    echo "You selected a number outside of the listed options, try again..."
  fi
done
