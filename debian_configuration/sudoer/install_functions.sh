# Install and configure vim
# Reference: http://vim.wikia.com/wiki/Indenting_source_code
install_vim () {
  apt-get --assume-yes install vim
  cat sudoer/templates/vimrc.local |tee /etc/vim/vimrc.local
}

# Install Google Chrome browser
install_chrome () {
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  dpkg -i google-chrome-stable_current_amd64.deb
  if [ $? -ne 0 ]; then
    # Reference: man 8 apt-get
    apt-get --assume-yes install -f
  fi
  dpkg -i google-chrome-stable_current_amd64.deb
  rm google-chrome-stable_current_amd64.deb
}

# configure_python3 () {
#  apt-get install python3-pip
#  # venv is a subset of virtualenv, so use virtualenv. Reference: https://stackoverflow.com/questions/41573587/what-is-the-difference-between-venv-pyvenv-pyenv-virtualenv-virtualenvwrappe
#  pip3 virtualenv
#}
# FAQ: 
# * How Maven compile Java source code? Answer: Maven compile source code by finding using the - javac - command in the OS

install_eclipse () {
  direct_download_link=$(python3 python/get_eclipse_package_direct_download_link.py)
  wget ${direct_download_link}
  tar_file_name=$(python3 python/utils.py get_str ${direct_download_link} ".*.tar.gz" "/")
  tar -xvzf ${tar_file_name} -C /opt/
  rm ${tar_file_name}
  # Refer to http://stackoverflow.com/questions/37864572/using-different-location-for-eclipses-p2-file
  ln -fs /opt/eclipse/eclipse /usr/bin/eclipse
  python3 python/add_to_gnome_main_menu.py eclipse /opt/eclipse/eclipse /opt/eclipse/icon.xpm
}

install_intellij () {
  direct_download_link=$(python3 python/get_idea_package_direct_download_link.py)
  wget ${direct_download_link}
  tar_file_name=$(ls idea*.tar.gz)
  tar -xvzf ${tar_file_name} -C /opt/
  rm ${tar_file_name}
  idea_dir=$(find /opt -type d -name idea*)
  ln -fs ${idea_dir}/bin/idea.sh /usr/bin/idea
  python3 python/add_to_gnome_main_menu.py Idea ${idea_dir}/bin/idea.sh /${idea_dir}/bin/idea.png
}


install_system_monitors () {
  apt-get install strace
  apt-get install htop
}
# $1 - user to add as sudoer 
#add_sudoer () {
#  user_name=$1
#  config_statement=$(grep '^root' /etc/sudoers)
#  [[ ! $(grep '^'${user_name} /etc/sudoers) ]] && echo ${config_statement/root/$user_name} >> /etc/sudoers
#  
#}

# Reference: https://docs.docker.com/engine/install/debian/
install_docker () {
  # Set up the repository
  apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
  # Add Docker's Official GPG key
  curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg 
  echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update
  apt-get install docker-ce docker-ce-cli containerd.io
}

# extra
install_postfix () {
  debconf-set-selections <<< "postfix postfix/mailname string example.com"
  debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
  apt-get install -y postfix
  sed -i "s/inet_interfaces =.*$/inet_interfaces = loopback-only/" /etc/postfix/main.cf 
}
