# Análisis de Drivers de Revenue – E-commerce (2011)

## Resumen del proyecto

Este proyecto analiza datos históricos de transacciones de un e-commerce para entender **qué factores impulsaron el crecimiento del revenue**.

A partir de un **pipeline reproducible en SQL (BigQuery)**, construí una **tabla mensual de KPIs** y un **dashboard ejecutivo en Tableau** para identificar si el crecimiento se debió a:

* más clientes,
* más pedidos,
* o mayor valor por cliente/pedido.

---

## Problema de negocio

**Stakeholder:** Head of E-commerce / Dirección General
**Pregunta clave:**

> Entre enero y noviembre de 2011, ¿el crecimiento del revenue estuvo impulsado principalmente por volumen (clientes/pedidos) o por valor (AOV/ARPU)?

Responder a esta pregunta permite priorizar estrategias de **adquisición**, **frecuencia de compra** o **pricing/valor**.

---

## Enfoque

1. **Reinicio del pipeline desde datos crudos** tras detectar inconsistencias en una versión inicial (gestión de devoluciones y definición de revenue).
2. Definición de una **única fuente de verdad en SQL** para los KPIs:

   * Net Revenue (North Star)
   * Active Customers
   * Orders
   * AOV / ARPU
   * Return Rate
3. Agregación **mensual** para asegurar comparaciones consistentes.
4. Conexión directa de la tabla BI a **Tableau**, manteniendo toda la lógica de negocio en SQL.
5. Diseño de un **dashboard ejecutivo limpio**, con una jerarquía clara:

   * Net Revenue arriba
   * Drivers de revenue debajo

Diciembre de 2011 se excluyó por ser un mes parcial y mostrar un comportamiento anómalo en devoluciones.

---

## Decisiones clave

* **Net Revenue** como métrica principal (incluye devoluciones).
* **Devoluciones tratadas explícitamente** (cantidades negativas convertidas a valor absoluto).
* **Orders y Active Customers** basados solo en compras (Quantity > 0).
* No se muestra símbolo de moneda en el dashboard, ya que el dataset no lo especifica explícitamente.

Todas las decisiones están documentadas y son reproducibles.

---

## Insights clave (ene–nov 2011)

* **Net Revenue acelera claramente entre septiembre y noviembre.**
* El crecimiento coincide con aumentos en **Active Customers** y **Orders**.
* **AOV y ARPU se mantienen relativamente estables**, sin una tendencia alcista sostenida.

### Conclusión ejecutiva

**El crecimiento del revenue en 2011 estuvo impulsado principalmente por el aumento del volumen (clientes y pedidos), más que por un mayor valor por cliente o por pedido.**

En resumen:
**Crecimos más por volumen que por valor.**

---

## Entregables

* Pipeline de datos en SQL (BigQuery)
* Tabla BI mensual de KPIs
* Dashboard en Tableau: **“Revenue Drivers – 2011 (Jan–Nov)”**
* README técnico + resumen recruiter-friendly

---

## Herramientas y habilidades

* **SQL (BigQuery)** – limpieza de datos, agregaciones, diseño de KPIs
* **Tableau** – dashboards ejecutivos y storytelling
* **Validación de datos** – sanity checks y consistencia de métricas
* **Análisis de negocio** – traducción de datos a decisiones

---

## Próximos pasos

* Análisis de retención por cohortes
* Segmentación RFM
* Drivers de revenue por producto y país
* Análisis de rentabilidad (si se dispone de costes)
