package tv.fleet.manager.maintenances.domain;

import java.time.LocalDate;
import java.util.Optional;
import java.util.UUID;
import tv.fleet.manager.shared.domain.MaintenanceId;
import tv.fleet.manager.vehicles.domain.VehicleId;
import tv.fleet.manager.Items.domain.Item;
import tv.fleet.manager.shared.domain.MaintenanceItem;
import tv.fleet.manager.maintenances.domain.MaintenanceType;
import tv.fleet.manager.maintenances.domain.RecurrencePolicy;
import tv.fleet.manager.maintenances.domain.Maintenance;
import tv.fleet.manager.maintenances.domain.MaintenanceConcept;

public class Main {
    public static void main(String[] args) {
        Maintenance maintenanceNonRecurrent = new Maintenance(
                new MaintenanceId(UUID.randomUUID().toString()),
                new VehicleId(UUID.randomUUID().toString()),
                Optional.of(LocalDate.of(2025, 3, 15)),
                new MaintenanceType("INTERNAL"),
                null, // No es recurrente
                new MaintenanceConcept("Cambio de aceite y revisión general")
        );
        maintenanceNonRecurrent.addItem(new Item(
            "Cambio de aceite", 50.0)
            );
        maintenanceNonRecurrent.addItem(new MaintenanceItem("Mano de obra", 30.0));
        System.out.println("No recurrente:\n" + maintenanceNonRecurrent + "\n");

        // Ejemplo 2: Mantenimiento recurrente SOLO por tiempo
        RecurrencePolicy timeOnlyPolicy = new RecurrencePolicy(6, null); // cada 6 meses
        Maintenance maintenanceTimeOnly = new Maintenance(
                new MaintenanceId(UUID.randomUUID().toString()),
                new VehicleId(UUID.randomUUID().toString()),
                Optional.of(LocalDate.of(2025, 4, 1)),
                new MaintenanceType("EXTERNAL"),
                timeOnlyPolicy,
                new MaintenanceConcept("Revisión periódica de frenos")
        );
        maintenanceTimeOnly.addItem(new MaintenanceItem("Revisión de frenos", 40.0));
        maintenanceTimeOnly.addItem(new MaintenanceItem("Alineación", 20.0));
        System.out.println("Recurrente por tiempo:\n" + maintenanceTimeOnly + "\n");

        // Ejemplo 3: Mantenimiento recurrente SOLO por kilómetros
        RecurrencePolicy kmOnlyPolicy = new RecurrencePolicy(null, 10000); // cada 10,000 km
        Maintenance maintenanceKmOnly = new Maintenance(
                new MaintenanceId(UUID.randomUUID().toString()),
                new VehicleId(UUID.randomUUID().toString()),
                Optional.empty(), // No se define fecha, solo por km
                new MaintenanceType("INTERNAL"),
                kmOnlyPolicy,
                new MaintenanceConcept("Inspección general basada en km")
        );
        maintenanceKmOnly.addItem(new MaintenanceItem("Inspección visual", 25.0));
        System.out.println("Recurrente por km:\n" + maintenanceKmOnly + "\n");

        // Ejemplo 4: Mantenimiento recurrente por ambos criterios (tiempo y km)
        RecurrencePolicy bothPolicy = new RecurrencePolicy(12, 15000); // cada 12 meses o 15,000 km
        Maintenance maintenanceBoth = new Maintenance(
                new MaintenanceId(UUID.randomUUID().toString()),
                new VehicleId(UUID.randomUUID().toString()),
                Optional.of(LocalDate.of(2025, 5, 10)),
                new MaintenanceType("EXTERNAL"),
                bothPolicy,
                new MaintenanceConcept("Mantenimiento completo: líquido, frenos y revisión")
        );
        maintenanceBoth.addItem(new MaintenanceItem("Cambio de líquido de frenos", 70.0));
        maintenanceBoth.addItem(new MaintenanceItem("Cambio de filtro", 35.0));
        maintenanceBoth.addItem(new MaintenanceItem("Mano de obra", 40.0));
        System.out.println("Recurrente por tiempo y km:\n" + maintenanceBoth + "\n");

        // Simulación de completado
        System.out.println("Simulación de completado de mantenimiento (por tiempo)...");
        maintenanceTimeOnly.completeMaintenance(5000);
        System.out.println("Después de completar (por tiempo):\n" + maintenanceTimeOnly + "\n");

        System.out.println("Simulación de completado de mantenimiento (por km)...");
        maintenanceKmOnly.completeMaintenance(10500);
        System.out.println("Después de completar (por km):\n" + maintenanceKmOnly + "\n");

        System.out.println("Simulación de completado de mantenimiento (por ambos criterios)...");
        maintenanceBoth.completeMaintenance(16000);
        System.out.println("Después de completar (por ambos):\n" + maintenanceBoth + "\n");
    }
}
