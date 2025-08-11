Here is a clear **step-by-step guide to test Debezium CDC (Change Data Capture)** from PostgreSQL to Redpanda/Kafka using the Debezium PostgreSQL connector:

---

## ✅ Step-by-Step CDC Testing

### 🔧 **Step 1: Ensure Debezium connector is running**

Run:

```bash
curl http://localhost:8083/connectors/debezium-postgres/status | jq
```

You should see:

```json
"state": "RUNNING"
```

Both for the `connector` and its `tasks`.

---

### 🧪 **Step 2: Verify PostgreSQL connector configuration**

Check which database, schema, and tables are included:

```bash
curl http://localhost:8083/connectors/debezium-postgres/config | jq
```

Look for:

* `database.hostname`
* `table.include.list` (or `schema.include.list`)
* `topic.prefix` (e.g., `cdc`)

Ensure the table you're testing is included.

---

### 📥 **Step 3: Make a data change in PostgreSQL**

Exec into the PostgreSQL pod:

```bash
kubectl exec -it <postgres-pod> -n <namespace> -- psql -U <username> -d <database>
```
<!-- postgresql-5dbb886c8b-xqv49 -->

```bash
kubectl exec -it postgresql-66f95cd5c-bv9zr -n test-deploy -- psql -U postgres -d testdb
kubectl exec -it postgresql-66f95cd5c-bv9zr -n test-deploy -- psql -U postgres -d cdcdb
```




Then run:

```sql
-- INSERT example
INSERT INTO public.product (id, name, price) VALUES (6, 'Test Product', 99.99);

-- UPDATE example
UPDATE public.product SET price = 8288 WHERE id = 3;

-- DELETE example
DELETE FROM public.product WHERE id = 6;
```

---

### 📡 **Step 4: Consume messages from the Kafka/Redpanda topic**

Find the correct topic. It usually follows this format:

```
<topic.prefix>.<schema>.<table>
```

Example:

```
cdc.public.product
```

Then run (with `rpk`):

```bash

rpk topic consume cdc.public.product --brokers localhost:9093 -f json -n 5
```

Or continuously:

```bash

rpk topic consume cdc.public.product --brokers localhost:9093 -f json | jq
```

Expected message format:

```json
{
  "before": null,
  "after": {
    "id": 101,
    "name": "Test Product",
    "price": 99.99
  },
  "op": "c",         // "c" = create, "u" = update, "d" = delete
  "ts_ms": 1721343340123
}
```

---

### 🔄 **Step 5: Validate**

* ✅ If your message appears → CDC is working.
* ❌ If not:

  * Confirm connector includes your table.
  * Confirm Postgres has `wal_level=logical`.
  * Check the replication slot exists:

    ```sql
    SELECT * FROM pg_replication_slots;
    ```

---

### 🎯 Summary:

| Action           | Command                                                          |
| ---------------- | ---------------------------------------------------------------- |
| Change Data      | SQL `INSERT`/`UPDATE`                                            |
| View Kafka Topic | `rpk topic consume <topic>`                                      |
| Check connector  | `curl http://localhost:8083/connectors/debezium-postgres/status` |