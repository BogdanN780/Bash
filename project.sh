login.sh
#!/bin/bash

users_file="/home/denisa/proiect_so/users.csv"

logged_in_file="/home/bogdan/proiect_so/logged_in_users.txt"

read -p "Nume utilizator: " username


user_line=$(grep "^.,${username},." "$users_file")

while  [ -z "$user_line" ]; do

  echo "Numele de utilizator '$username' nu există."

  read -p "Try Again: " username

user_line=$(grep "^.,${username},." "$users_file")

done

if [ ! -z "$user_line" ]; then

read -sp "Parolă: " password

fi

 

stored_hashed_password=$(echo "$user_line" | cut -d ',' -f 4)

pw_check_hash=$(echo "$password" | openssl sha256) 


while [ "$pw_check_hash" != "$stored_hashed_password" ]; do

  echo "Parola este incorectă."

  read -sp "Introdu parola corecta: " password

  pw_check_hash=$(echo "$password" | openssl sha256) 

 

done

now=$(date "+%Y-%m-%d %H:%M:%S")

user_line=$(grep "^.,${username},." "$users_file")

new_user_line=$(echo "$user_line" | sed "s|\(.\),[^,]$|\1,$now|")

sed -i "s|^.,$username,.$|$new_user_line|" "$users_file"

if ! grep -q "^$username$" "$logged_in_file"; then

  echo "$username" >> "$logged_in_file"

fi

 

user_id=$(echo "$user_line" | cut -d ',' -f 1)

email=$(echo "$user_line" | cut -d ',' -f 3)

user_dir=$(echo "$user_line" | cut -d ',' -f 5)

now=$(echo "$user_line" | cut -d ',' -f 6)

echo "Autentificare reușită pentru '$username'."

 

while IFS=',' read -r ID Username Email Password Home_Director Last_Login

do

echo "Id: $user_id"

echo "Username: $username"

echo "Email: $email"

echo "Directorul: $user_dir"

echo "Ultima oara cand te-ai logat: $now"

echo

echo -----------------------------------------------

done < <( tail -n 1 users.csv)

cd "/home/denisa/proiect_so/$username"

logout.sh
#!/bin/bash
logged_in_file="/home/denisa/proiect_so/logged_in_users.txt"

user_file="/home/bogdan/proiect_so/users.csv"

read -p "Nume utilizator: " username

user_line=$(grep "^.,${username},." "$user_file")

if ! grep -q "^$username$" "$logged_in_file"; then

  echo "Utilizatorul '$username' nu este autentificat."

else

read -sp "Parolă: " password

stored_hashed_password=$(echo "$user_line" | cut -d ',' -f 4)

pw_check_hash=$(echo "$password" | openssl sha256)

while [ "$pw_check_hash" != "$stored_hashed_password" ]; do

  echo "Parola este incorectă."

  read -sp "Parola Corecta: " password

 pw_check_hash=$(echo "$password" | openssl sha256) 

done

sed -i "/^$username$/d" "$logged_in_file"

echo "Deconectare reușită pentru '$username'."

 

fi
menu.sh
#!/bin/bash

#./register_user.sh

#./login.sh

#./logout.sh

#./user_raport.sh

echo "1.Inregistrare"

echo "2.Conectare"

echo "3.Deconectare"

while true; do

read -p "Alege o optiune" choice

if [ $choice -eq 1 ]; then

./register_user.sh

elif [ $choice -eq 2 ]; then

./login.sh

elif [ $choice -eq 3 ]; then

./logout.sh

break

else 

echo "Te rog alege o optiune valida 1-3"

fi

done
register_user.sh

#!/bin/bash
read -p "Nume utilizator: " username

while cut -d ',' -f 2 users.csv | grep -q "^$username$"; do
  echo "Un utilizator cu numele '$username' există deja."

  read -p "Incearca alt nume de utilizator:" username

done
read -p "Adresă e-mail: " email
read -sp "Parolă: " password

echo

read -sp "Confirmați parola: " confirm_password

echo
while [ "$password" != "$confirm_password" ]; do

  read -sp "Parolele nu coincid. Te rog sa introduci parola din nou:" confirm_password

echo

done
if [ "$password" == "$confirm_password" ]; then

echo "FELICITARI! Te-ai inregistrat cu succes"

echo

echo "Bine ai venit, $username!"

echo

fi
user_id=$(uuidgen)
hashed_password=$(echo "$password" | openssl sha256)
now=$(date +%Y-%m-%d_%H-%M-%S) 
user_dir="/home/bogdan/proiect_so/$username"

mkdir "$user_dir"
echo "$user_id,$username,$email,$hashed_password,$user_dir,$now" >> users.csv
echo "Utilizatorul a fost inregistrat cu succes!"

while IFS=',' read -r ID USERNAME EMAIL PASSW DIRECTOR LASTLOG

do

echo "Id-ul este: $user_id"

echo "Username-ul tau este: $username"

echo "Email-ul este: $email"

echo "Parola: : $hashed_password"

echo "Directorul tau : $user_dir"

echo "Ultima oara cand te-ai logat: $now"

echo

echo -----------------------------------------------

done < <( tail -n 1 users.csv)
user_report.sh
#!/bin/bash
if [ $# -eq 0 ]; then
  echo "Foloseste urmatoarea sintaxa: source user_raport.sh  <username>"
  return 1
fi
username="$1"
user_dir="/home/bogdan/proiect_so/$username" 
if [ ! -d "$user_dir" ]; then

  echo "Utilizatorul '$username' nu există sau nu are un director personal."

  return 1
fi
num_files=$(find "$user_dir" -type f | wc -l)
num_dirs=$(find "$user_dir" -type d | wc -l)
num_dirs=$((num_dirs - 1))
total_size=$(du -sh "$user_dir" | cut -f1)
echo "Raport utilizator '$username':" > "$user_dir/raport"
echo "Numărul de fișiere: $num_files" >> "$user_dir/raport"
echo "Numărul de directoare: $num_dirs" >> "$user_dir/raport"
echo "Dimensiunea totală a fișierelor: $total_size" >> "$user_dir/raport"
echo "Raport generat cu succes pentru utilizatorul '$username'."
