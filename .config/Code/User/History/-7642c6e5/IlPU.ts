import { authFetch } from "@/modules/shared/infrastructure/api/authFetch";
import { UserRepository } from "../domain/UserRepository";

const BASE_URL = 'http://localhost:8080/api/admin';  // Ruta a tu backend de Spring Boot

export class ApiAuthRepository implements UserRepository {

    // Obtener lista de usuarios
    public async retrieveUsers() {
        const response = await authFetch(`${BASE_URL}/users`, {
            method: 'GET'
        });

        if (!response.ok) {
            throw new Error('Error al obtener los usuarios');
        }

        console.log('me he llamado')

        return response.json();
    }
        
    // Crear usuario
    public async createUser(user: { username: string, email: string, password: string }) {
        const response = await authFetch(`${BASE_URL}/users`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                username: user.username,
                email: user.email,
                enabled: true,
                credentials: [
                    {
                        type: 'password',
                        value: user.password,
                        temporary: false,
                    },
                ],
            }),
        });

        if (!response.ok) {
            throw new Error('Error al crear el usuario');
        }

        return response.json();
    };

    // Asignar rol a un usuario
    public async assignRoleToUser(userId: string, roleName: string) {
        const response = await authFetch(`${BASE_URL}/users/${userId}/roles`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ roleName }),
        });

        if (!response.ok) {
            throw new Error('Error al asignar el rol');
        }

        return response.json();
    };

    // Eliminar usuario
    public async deleteUser(userId: string) {
        const response = await authFetch(`${BASE_URL}/users/${userId}`, {
            method: 'DELETE',
        });

        if (!response.ok) {
            throw new Error('Error al eliminar el usuario');
        }

        return response.json();
    }
}