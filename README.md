# .dotfiles

My custom dotfiles using oh-my-zsh and dotbot

## Restore Instructions

1. `xcode-select --install` (Command Line Tools are required for Git and Homebrew)
2. `git clone https://github.com/BrChung/.dotfiles.git ~/.dotfiles`. We'll start with `https` but switch to `ssh` after everything is installed.
3. `cd ~/.dotfiles`
4. You need to change the contents of `gitconfig` to your own.
5. Do one last Software Audit by editing [Brewfile](Brewfile) directly.
6. [`./install`](install)
7. Restart computer.
8. [Generate ssh key](https://help.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh), add to GitHub, and switch remotes.

   ```zsh
   # Generate SSH key in default location (~/.ssh/config) [Note: change comment with your no-reply email address]
   ssh-keygen -t rsa -b 4096 -C "35940686+BrChung@users.noreply.github.com"

   # Start the ssh-agent
   eval "$(ssh-agent -s)"

   # Create config file with necessary settings
   << EOF > ~/.ssh/config
   Host *
     AddKeysToAgent yes
     UseKeychain yes
     IdentityFile ~/.ssh/id_rsa
   EOF

   # Add private key to ssh-agent
   ssh-add -K ~/.ssh/id_rsa

   # Copy public key and add to github.com > Settings > SSH and GPG keys
   pbcopy < ~/.ssh/id_rsa.pub

   # Test SSH connection, then verify fingerprint and username
   # https://help.github.com/en/github/authenticating-to-github/testing-your-ssh-connection
   ssh -T git@github.com

   # Switch from HTTPS to SSH
   git remote set-url origin git@github.com:BrChung/.dotfiles.git
   ```

## What you get

- Homebrew
- oh-my-zsh
- Node/NVM
- Awesome mac applications
- Some terminal aliases and functions in oh-my-zsh/aliases.zsh

## License

The contents of this repository are covered under the [MIT License](LICENSE).
