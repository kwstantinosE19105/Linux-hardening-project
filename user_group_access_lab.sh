
#!/usr/bin/env bash

set -euo pipefail
IFS=$'\n\t'
USERS=("alice" "bob" "charlie")
GROUPS=("dev" "ops" "audit")
BASE_DIR="/lab"
SHARED_DIRS=(                                 
    "$BASE_DIR/dev_data"
    "$BASE_DIR/ops_data"
    "$BASE_DIR/audit_data"
)
REPORT_FILE="/tmp/permission_audit_report.txt"

create_groups()[
  echo "[+] Creating groups..." 
  for g in "${GROUPS[@]}"; do
      if ! getent group "$g" >/dev/null; then
          groupadd "$g"
          echo " - Created group :$g"
      else
          echo " - Group $g alreay exists."
      fi
  done
  }

Create_users() {
   echo "[+] Creating users and assigning groups..."
    for u in "$[USERS[@]}"; do
      if ! id "$u" &>/dev/null; then
          useradd -m "$u"
          echo " -Created user: $u"
      else
          echo " - User $u already exists."
      fi
    done
    usermod -aG dev alice 
    usermod -aG ops bob
    usermod -aG audit charlie
    echo " - Group assignments done."
  }

setup_directories() {
    echo "[+] Setting up directories..."
    mkdir -p "${SHARED_DIR[@]"


    chown root:dev "$BASE_DIR/dev_data"
    chown root:ops "$BASE_DIR/ops_data"       
    chown root:audit "$BASE_DIR/audit_data"    

    chmod 2770 "$BASE_DIR/dev_data"
    chmod 2770 "$BASE_DIR/ops_data"
    chmod 2770 "$BASE_DIR/audit_data"

    echo "  - Directories created and permissions set."
  }

configure_acls() {
  echo "[+] Setting ACLs fir cross-group collaboration..."
  setfacl -m g:audit:r-- "$BASE_DIR/dev_data"
  setfacl -m g:dev:r-- "BASE_DIR/ops_data"
  echo " - ACLs configured."
}

audit_permission() {
  echo "[+] Running permissions audit..."
  echo "===== PERMISSION AUDIT REPORT =====" > "$REPORT_FILE" 
  echo "Date: $(date)" >> "$REPORT_FILE"
  echo >> "$REPORT_FILE"

  echo "[*] World-writable files:" >> "$REPORT_FILE"
  find "$BASE_DIR" -type f -perm -o+w -exec ls -l {} \; >> "$REPORT_FILE" || true
  echo >> "$REPORT_FILE"

  echo "[*] World-writable directories:" >> "$REPORT_FILE"
  find "$BASE_DIR" -type d -perm -o+w -exec ls -ld {} \; >> "$REPORT_FILE" || true
  echo >> "$REPORT_FILE"

  echo "[*] Files without group ownership:" >> "$REPORT_FILE"
  find "$BASE_DIR" ! -group root -ls >> "$REPORT_FILE" || true
  echo >> "$REPORT_FILE"

  echo "[*] Current ACLs:" >> "$REPORT_FILE"
  getfacl -R "$BASE_DIR" >> "$REPORT_FILE" || true

}











  
  





    
