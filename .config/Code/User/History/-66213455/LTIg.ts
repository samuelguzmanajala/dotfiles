export interface Maintenance {
    id: string;
    vehicleId: string;
    vehiclePlate: string;
    maintenanceConcept: string;
    maintenanceDueDate: string;
    maintenanceRecurrenceType: string;
    type: string;
    status: string;
    total: number;
    maintenanceRecurrenceIntervalKilometers: number;
    maintenanceRecurrenceIntervalTime: number;
    maintenanceRecurrenceTimeUnit: string;
    items: MaintenanceItem[];
}

export interface MaintenanceItem {
    id: string;
    name: string;
    stock: number;
    unit: string;
    category: string;
    price: number;
    sellPrice: number;
    minimumStock: number;
}