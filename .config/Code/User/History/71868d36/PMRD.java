package tv.fleet.manager.maintenances.domain;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import tv.fleet.manager.Items.domain.Item;
import tv.fleet.manager.shared.domain.MaintenanceId;
import tv.fleet.manager.shared.domain.MaintenanceItem;
import tv.fleet.manager.vehicles.domain.VehicleId;

public class Maintenance {
    private final MaintenanceId id;
    private final VehicleId vehicleId;
    private MaintenanceStatus status;
    // La fecha esperada para realizar el mantenimiento. Puede ser vacía si la recurrencia es
    // exclusivamente por kilómetros.
    private Optional<LocalDate> scheduledDate;
    private final MaintenanceType type;

    private final List<Item> items;
    // Si el mantenimiento es recurrente, se define su política; de lo contrario, puede ser null.
    private final RecurrencePolicy recurrencePolicy;
    // Almacena el kilometraje registrado en el último mantenimiento.
    private int kmsAtLastMaintenance;

    private MaintenanceConcept concept;

    /**
     * @param id             Identificador del mantenimiento.
     * @param vehicleId      Identificador del vehículo.
     * @param scheduledDate  Fecha esperada para el mantenimiento (opcional).
     * @param type           Tipo de mantenimiento (interno o externo).
     * @param recurrencePolicy Política de recurrencia; si es null, el mantenimiento no es recurrente.
     */
    public Maintenance(MaintenanceId id, VehicleId vehicleId, Optional<LocalDate> scheduledDate,
                       MaintenanceType type, RecurrencePolicy recurrencePolicy, MaintenanceConcept concept) {
        this.id = id;
        this.vehicleId = vehicleId;
        this.scheduledDate = scheduledDate;
        this.type = type;
        this.recurrencePolicy = recurrencePolicy;
        this.status = new MaintenanceStatus("PENDING");
        this.kmsAtLastMaintenance = 0;
        this.items = List.of();
        this.concept = concept;
    }

    // Getters
    public MaintenanceId id() {
        return id;
    }

    public MaintenanceStatus status() {
        return status;
    }

    public Optional<LocalDate> scheduledDate() {
        return scheduledDate;
    }

    public MaintenanceType type() {
        return type;
    }

    public List<Item> items() { return new ArrayList<>(items); }

    public MaintenanceConcept concept() { return concept; }

    public int kmsAtLastMaintenance() {
        return kmsAtLastMaintenance;
    }

    public void addItem(Item item) {
        items.add(item);
    }

    public double totalCost() {
        return items.stream().mapToDouble(item -> item.price().value().doubleValue()).sum();
    }

    /**
     * Marca el mantenimiento como completado y, si existe una política de recurrencia y se cumplen los
     * criterios (por tiempo o por kilómetros), reagenda el mantenimiento.
     *
     * @param currentKms Kilometraje actual del vehículo.
     */
    public void completeMaintenance(int currentKms) {
        if (!status.isPending()) {
            throw new IllegalStateException("El mantenimiento no está pendiente y no puede completarse.");
        }
        // Marca como completado y actualiza el kilometraje del último mantenimiento.
        status = new MaintenanceStatus("COMPLETED");
        kmsAtLastMaintenance = currentKms;
        // (Se pueden publicar eventos de dominio aquí)

        // Si existe política de recurrencia y se cumplen los criterios, reagendar.
        if (recurrencePolicy != null &&
            recurrencePolicy.shouldReschedule(scheduledDate, currentKms, kmsAtLastMaintenance)) {
            reschedule();
        }
    }

    /**
     * Reagenda el mantenimiento según la política:
     *   - Si se define un criterio por tiempo, se calcula la próxima fecha.
     *   - Si la política es solo por kilómetros, la fecha se mantiene sin asignar (Optional.empty()).
     * Luego, se establece el estado en PENDING para el próximo ciclo.
     */
    private void reschedule() {
        Optional<LocalDate> newDate = recurrencePolicy.computeNextDate(scheduledDate);
        this.scheduledDate = newDate;
        status = new MaintenanceStatus("PENDING");
        // (Se pueden publicar eventos de dominio aquí)
    }

    /**
     * Si existe una fecha programada (criterio de tiempo) y ya se ha pasado, marca el mantenimiento
     * como vencido (OVERDUE).
     */
    public void checkAndMarkOverdue() {
        if (scheduledDate.isPresent() &&
            status.isPending() &&
            LocalDate.now().isAfter(scheduledDate.get())) {
            status = new MaintenanceStatus("OVERDUE");
            // (Se puede publicar un evento de mantenimiento vencido)
        }
    }

    @Override
    public String toString() {
        return "Maintenance{" +
                "id=" + id +
                ", vehicleId=" + vehicleId +
                ", status=" + status +
                ", scheduledDate=" + (scheduledDate.isPresent() ? scheduledDate.get() : "None") +
                ", type=" + type +
                ", kmsAtLastMaintenance=" + kmsAtLastMaintenance +
                ", recurrencePolicy=" + (recurrencePolicy != null
                    ? ("[weeks=" + recurrencePolicy.getWeeksInterval() +
                      ", kmThreshold=" + recurrencePolicy.getKmThreshold() + "]")
                    : "None") +
                ", concept=" + concept +
                ", items=" + items +
                ", totalCost=" + totalCost() +
                '}';
    }
}

