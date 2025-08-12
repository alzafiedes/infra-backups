#!/usr/bin/env bash
# backup_mysql_basic.sh
# Lee variables del entorno que setea el Jenkinsfile (no necesita argumentos)
set -euo pipefail

: "${MYSQL_HOST:?falta MYSQL_HOST}"
: "${MYSQL_PORT:=3306}"
: "${DB_USER:?falta DB_USER}"
: "${DB_PASS:?falta DB_PASS}"
: "${BACKUP_DIR:?falta BACKUP_DIR}"
: "${MYSQL_OPTS:=--single-transaction}"
: "${MYSQL_ALL:=true}"
: "${MYSQL_DBS:=}"   # CSV si no es all

mkdir -p "${BACKUP_DIR}"
TS="$(date +%F_%H%M%S)"
OUT="${BACKUP_DIR}/mysql_backup_${TS}.sql"
LOG="${BACKUP_DIR}/mysqldump_${TS}.log"

BASE=(mysqldump -h "${MYSQL_HOST}" -P "${MYSQL_PORT}" -u "${DB_USER}" --password="${DB_PASS}")

if [[ "${MYSQL_ALL}" == "true" ]]; then
  echo "[INFO] Dump de TODAS las BDs" | tee -a "${LOG}"
  "${BASE[@]}" ${MYSQL_OPTS} --all-databases > "${OUT}" 2>> "${LOG}"
else
  if [[ -z "${MYSQL_DBS}" ]]; then
    echo "[ERROR] MYSQL_ALL=false pero no se definió MYSQL_DBS" | tee -a "${LOG}"
    exit 1
  fi
  IFS=',' read -r -a DBS <<< "${MYSQL_DBS}"
  echo "[INFO] Dump de BDs: ${MYSQL_DBS}" | tee -a "${LOG}"
  for db in "${DBS[@]}"; do
    "${BASE[@]}" ${MYSQL_OPTS} --databases "${db}" >> "${OUT}" 2>> "${LOG}"
  done
fi

# compresión simple (opcional: comenta si no la quieres)
gzip -9 "${OUT}"
echo "[OK] Backup generado: ${OUT}.gz" | tee -a "${LOG}"
