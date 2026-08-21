import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  HttpCode,
  HttpStatus,
  ParseUUIDPipe,
  UseGuards,
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // Create a new user (public)
  @Post()
  @HttpCode(HttpStatus.CREATED)
  async create(@Body() createUserDto: CreateUserDto) {
    const user = await this.usersService.create(createUserDto);
    return {
      message: 'User created successfully',
      data: user,
    };
  }

  // Get all users (protected)
  @Get()
  @UseGuards(JwtAuthGuard)
  async findAll(
    @Query('isActive') isActive?: string,
    @Query('role') role?: string,
  ) {
    const filters: any = {};
    if (isActive !== undefined) filters.isActive = isActive === 'true';
    if (role) filters.role = role;

    const users = await this.usersService.findAll(filters);
    return {
      message: 'Users retrieved successfully',
      data: users,
      count: users.length,
    };
  }

  // Get user by ID (protected)
  @Get(':id')
  @UseGuards(JwtAuthGuard)
  async findOne(@Param('id') id: string) {
    const user = await this.usersService.findOne(id);
    return {
      message: 'User retrieved successfully',
      data: user,
    };
  }

  // Update user (protected)
  @Patch(':id')
  @UseGuards(JwtAuthGuard)
  async update(
    @Param('id') id: string,
    @Body() updateUserDto: UpdateUserDto,
  ) {
    const user = await this.usersService.update(id, updateUserDto);
    return {
      message: 'User updated successfully',
      data: user,
    };
  }

  // Soft delete user (protected)
  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  async remove(@Param('id') id: string) {
    const user = await this.usersService.remove(id);
    return {
      message: 'User deactivated successfully',
      data: user,
    };
  }

  // Hard delete user (protected - admin only)
  @Delete(':id/hard')
  @UseGuards(JwtAuthGuard)
  @HttpCode(HttpStatus.NO_CONTENT)
  async hardDelete(@Param('id') id: string) {
    await this.usersService.hardDelete(id);
  }

  // Get user statistics (protected)
  @Get('stats/dashboard')
  @UseGuards(JwtAuthGuard)
  async getStats() {
    const stats = await this.usersService.getUserStats();
    return {
      message: 'User statistics retrieved',
      data: stats,
    };
  }
}
