if [ -z "$SSH_AGENT_PID" ]; then
    eval `ssh-agent.exe`
    ssh-add.exe $HOME/.ssh/id_rsa
fi

vagrant ssh
