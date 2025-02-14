import { Injectable } from '@nestjs/common';

export type User = {
  id: number;
  username: string;
  password: string;
};

@Injectable()
export class UsersService {
  private readonly users: User[] = [
    {
      id: 1,
      username: 'john',
      password: 'changeme',
    },
    {
      id: 2,
      username: 'maria',
      password: 'guess',
    },
    {
      id: 3,
      username: 'test',
      password: 'test',
    },
  ];

  async findOne(username: string): Promise<User | undefined> {
    return this.users.find(user => user.username === username);
  }
} 