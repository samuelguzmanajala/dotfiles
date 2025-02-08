package tv.fleet.manager.maintenances.domain;

import java.time.LocalDate;
import java.util.Optional;

class RecurrencePolicy {
    private final Optional<Integer> weeksInterval; // Intervalo en semanas para recurrencia temporal
    private final Optional<Integer> kmThreshold;   // Umbral de kilómetros para recurrencia por uso
    
    public RecurrencePolicy(Integer weeksInterval, Integer kmThreshold) {
        if (weeksInterval != null && weeksInterval <= 0) {
            throw new IllegalArgumentException("El intervalo de semanas debe ser mayor a 0");
        }
        if (kmThreshold != null && kmThreshold <= 0) {
            throw new IllegalArgumentException("El umbral de kilómetros debe ser mayor a 0");
        }
        this.weeksInterval = Optional.ofNullable(weeksInterval);
        this.kmThreshold = Optional.ofNullable(kmThreshold);
    }

    public Optional<Integer> getWeeksInterval() {
        return weeksInterval;
    }

    public Optional<Integer> getKmThreshold() {
        return kmThreshold;
    }

    /**
     * Determina si se debe reagendar el mantenimiento basado en:
     * 1. Criterio temporal: fecha programada pasada
     * 2. Criterio de uso: kilómetros recorridos desde último mantenimiento
     * 3. Ambos criterios combinados
     */
    public boolean shouldReschedule(Optional<LocalDate> scheduledDate, int currentKms, int kmsAtLastMaintenance) {
        boolean shouldReschedule = false;
        
        // Criterio temporal
        if (weeksInterval.isPresent() && scheduledDate.isPresent()) {
            shouldReschedule = LocalDate.now().isAfter(scheduledDate.get());
        }
        
        // Criterio de uso
        if (kmThreshold.isPresent()) {
            int kmsSinceLastMaintenance = currentKms - kmsAtLastMaintenance;
            shouldReschedule = shouldReschedule || kmsSinceLastMaintenance >= kmThreshold.get();
        }
        
        return shouldReschedule;
    }

    /**
     * Calcula la próxima fecha de mantenimiento considerando ambos criterios:
     * 1. Si hay intervalo de semanas, suma al último mantenimiento
     * 2. Si solo hay umbral de km, retorna Optional.empty()
     */
    public Optional<LocalDate> computeNextDate(Optional<LocalDate> lastMaintenanceDate) {
        if (!weeksInterval.isPresent()) {
            return Optional.empty();
        }
        
        return lastMaintenanceDate.map(date -> date.plusWeeks(weeksInterval.get()));
    }
}
