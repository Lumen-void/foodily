import { UserRole } from '../../types/domain.types';

export interface RequestUser {
  id: string;
  role: UserRole;
  phone?: string;
}
