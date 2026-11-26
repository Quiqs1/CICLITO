# CICLITO — Cantera y Pedal

Sistema de renta y flota de bicicletas (Oracle 23c + FastAPI + React).

## Arranque

1. Base de datos: contenedor `oracle-ciclito` en el puerto 1521, scripts de `01_base_de_datos/` ya aplicados.
2. Backend:

```bash
cd 02_portal_web/backend
venv\Scripts\activate
pip install -r requirements.txt
python scripts/set_demo_passwords.py
uvicorn app.main:app --reload --port 8000
```

3. Frontend:

```bash
cd 02_portal_web/frontend
npm install
npm run dev
```

- API: http://localhost:8000/docs
- UI: http://localhost:5173

Cuentas semilla (después del script de hashes): password `Ciclito2026#`

- Admin: `admin@canteraypedal.mx`
- Empleado: `lupita.ruiz@canteraypedal.mx`
- Cliente: `diego.lopez@gmail.com`
