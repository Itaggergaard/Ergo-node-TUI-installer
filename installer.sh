#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

sudo apt install dialog -y
sudo apt update -y
sudo apt upgrade -y

user=$(whoami)



# Dialog box asking if the user wants to install dependencies
dialog --title "Dependencies" --yesno "Before we begin, we need to install the following dependencies: JRE, Wget, Dialog. Do you want to continue?" 0 0 || {
    echo "User aborted. Exiting."
    exit 1
}

# Install the necessary dependencies
sudo apt install default-jre -y
sudo apt install dialog -y
sudo apt install wget -y

# Go to root directory
cd "$HOME" || {
    echo "Error: Unable to change directory to $HOME. Exiting."
    exit 1
}

# Dialog box that starts the creation of the installation directory
dialog --title "Installation path" --msgbox "This will install the node in the following directory $HOME/ergo_node" 0 0

directory="ergo_node"

# Check if directory already exists
if [ ! -d "$directory" ]; then
    mkdir -v "$directory" > /dev/null || {
        echo "Error: Unable to create directory $directory. Exiting."
        exit 1
    }
    echo "[+] Ergo directory successfully created"
else
    echo "[!] The directory already exists, impossible to create another one with the same name"
fi

# Change directory to ergo_node
cd "$HOME/ergo_node" || {
    echo "Error: Unable to change directory to $HOME/ergo_node. Exiting."
    exit 1
}

# Creates a dialog box to choose the node type
var=$(dialog --title "Node selection" --menu "Select a node" 0 0 0 \
    1 "Light Node" \
    2 "Full Archival Node" \
    3 "Full Pruned Node" \
    3>&1 1>&2 2>&3 3>&-)

case $var in
    1)
        # Light option was selected, modify ergo.conf
        dialog --title "Success" --msgbox "Light node" 0 0
        cat <<EOF >ergo.conf
ergo {
  node {
    stateType = "digest"
    blocksToKeep = 1440
    mining = false
    nipopow {
      nipopowBootstrap = true
      p2pNipopows = 2
    }
  }
}

scorex {
  restApi {
    apiKeyHash = "6ed54addddaf10fe8fcda330bd443a57914fbce38a9fa27248b07e361cc76a41"
  }
}
EOF

wget -P $HOME/ergo_node/ https://github.com/ergoplatform/ergo/releases/download/v5.0.20/ergo-5.0.20.jar
        ;;
    2)
        # Full option was selected
       dialog --title "Success" --msgbox "Full Archival Node" 0 0
cat <<EOF >ergo.conf
       ergo {
    node {
        mining = false
    }
}
EOF

wget -P $HOME/ergo_node/ https://github.com/ergoplatform/ergo/releases/download/v5.0.20/ergo-5.0.20.jar
        ;;
    3)
        dialog --title "Success" --msgbox "Full Pruned Node" 0 0
cat <<EOF >ergo.conf
ergo {
    node {
        mining = false

        utxo {
           utxoBootstrap = true
           storingUtxoSnapshots = 0
        }
        nipopow {
           nipopowBootstrap = true
           p2pNipopows = 2
        }
    }

}

scorex {
    restApi {
        apiKeyHash = "324dcf027dd4a30a932c441f365a25e86b173defa4b8e58948253471b81b72cf"
    }
}

EOF

wget -P $HOME/ergo_node/ https://github.com/ergoplatform/ergo/releases/download/v5.0.20/ergo-5.0.20.jar
        ;;
    *)
        # Default option, should not occur in this case
        echo "Invalid selection."
        ;;
esac

# Dialog box asking if the user wants to start the node
dialog --title "Installation finished" --yesno "Do you wish to start your node now?" 0 0 || {
    echo "User aborted. Exiting."
    exit 0cd..
    
}

# Start the node
java -jar $HOME/ergo_node/ergo-5.0.20.jar --mainnet -c ergo.conf

