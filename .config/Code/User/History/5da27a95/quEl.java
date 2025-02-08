package tv.fleet.manager.maintenances.domain;

import java.time.LocalDate;
import java.util.Optional;

class RecurrencePolicy {
    private final Optional<Integer> monthsInterval; // Ej.: 6 para cada 6 meses, 12 para cada 12 meses
    private final Optional<Integer> kmThreshold;      // Ej.: 10000 para cada 10.000 km

    public RecurrencePolicy(Integer monthsInterval, Integer kmThreshold) {
        this.monthsInterval = Optional.ofNullable(monthsInterval);
        this.kmThreshold = Optional.ofNullable(kmThreshold);
    }

    public Optional<Integer> getMonthsInterval() {
        return monthsInterval;
    }

    public Optional<Integer> getKmThreshold() {
        return kmThreshold;
    }

    /**
     * Determina si se debe reagendar el mantenimiento.
     * 
     * Se cumplen las condiciones si:
     *   - Existe una fecha programada y ya pasó (condición por tiempo), o
     *   - Se ha recorrido la cantidad de kilómetros indicada (condición por kilómetros).
     *
     * @param scheduledDate        Fecha programada (puede estar vacía si no se usa criterio temporal)
     * @param currentKms           Kilometraje actual del vehículo
     * @param kmsAtLastMaintenance Kilometraje en el último mantenimiento
     * @return true si se cumple al menos uno de los criterios de reagendamiento
     */
    public boolean shouldReschedule(Optional<LocalDate> scheduledDate, int currentKms, int kmsAtLastMaintenance) {
        boolean timeCondition = scheduledDate.isPresent() && LocalDate.now().isAfter(scheduledDate.get());
        boolean kmCondition = kmThreshold.isPresent() && (currentKms - kmsAtLastMaintenance >= kmThreshold.get());
        return timeCondition || kmCondition;
    }

    /**
     * Calcula la siguiente fecha de mantenimiento usando el criterio de tiempo, si se define.
     * Si no se ha configurado un intervalo en meses, se retorna Optional.empty().
     *
     * @param currentScheduledDate Fecha programada actual
     * @return La próxima fecha de mantenimiento (si el criterio de tiempo está definido)
     */
    public Optional<LocalDate> computeNextDate(Optional<LocalDate> currentScheduledDate) {
        if (currentScheduledDate.isPresent() && monthsInterval.isPresent()) {
            return Optional.of(currentScheduledDate.get().plusMonths(monthsInterval.get()));
        }
        return Optional.empty();
    }
}
