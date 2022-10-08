processor_architecture=$(lscpu | grep Architecture | awk '{ print $2 }')

if [[ "$processor_architecture" == "x86_64" ]]; then
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  sudo apt install -y unzip
  unzip awscliv2.zip
  sudo ./aws/install
else
  curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
  sudo apt install -y unzip
  unzip awscliv2.zip
  sudo ./aws/install
fi
