#!/bin/bash

sudo -v # ask for password only at the beginning

brew update
brew upgrade
brew tap homebrew/versions
brew tap phinze/homebrew-cask

brew install ack
brew install bash
brew install brew-cask
brew install git
brew install php composer
brew install --HEAD drush
brew install imagemagick

brew install node
brew install phantomjs
brew install sqlite
brew install tig
brew install the_silver_searcher
brew install tmux
brew install vim
brew install wget --enable-iri

brew cask install adobe-creative-cloud
brew cask install apptrap
brew cask install alfred
brew cask alfred link
brew cask install dropbox
brew cask install evernote
brew cask install f-lux
brew cask install fantastical
brew cask install firefox
brew cask install google-chrome
brew cask install hazel
brew cask install instacast
brew cask install iterm2
brew cask install kaleidoscope
brew cask install macvim
brew cask install sequel-pro
brew cask install soulver
brew cask install tower
brew cask install typinator
brew cask install virtualhostx
brew cask install vlc
brew cask install self-control
brew cask install skype
brew cask install ynab
