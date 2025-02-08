package tv.fleet.manager.maintenances.domain;

import tv.fleet.shared.domain.StringValueObject;

import java.util.Set;

public class MaintenanceStatus extends StringValueObject {

    private static final Set<String> VALID_TYPES = Set.of("PENDING", "COMPLETED", "OVERDUE");

    public MaintenanceStatus(String value) {
        super(ensureIsValid(value));
    }

    public MaintenanceStatus() {
        super(null);
    }

    public boolean isPending() {
        return value().equals("PENDING");
    }

    public boolean isCompleted() {
        return value().equals("COMPLETED");
    }

    public boolean isOverdue() {
        return value().equals("OVERDUE");
    }

    private static String ensureIsValid(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("The maintenance type is required");
        }

        if (!VALID_TYPES.contains(value)) {
            throw new IllegalArgumentException("Invalid maintenance type");
        }
        return value;
    }
}
