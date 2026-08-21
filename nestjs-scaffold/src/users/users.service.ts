import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import * as bcrypt from 'bcrypt';
import { ConfigService } from '@nestjs/config';
import { User, UserDocument } from './schemas/user.schema';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(
    @InjectModel(User.name) private userModel: Model<UserDocument>,
    private configService: ConfigService,
  ) {}

  // Create a new user with hashed password
  async create(createUserDto: CreateUserDto): Promise<User> {
    const { email, password, ...rest } = createUserDto;

    // Check if user already exists
    const existingUser = await this.userModel.findOne({ email }).exec();
    if (existingUser) {
      throw new ConflictException(`User with email ${email} already exists`);
    }

    // Hash the password
    const saltRounds = this.configService.get<number>('bcrypt.saltRounds') || 10;
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create user with hashed password
    const user = new this.userModel({
      ...rest,
      email,
      password: hashedPassword,
    });

    await user.save();
    return user;
  }

  // Find all users with optional filters
  async findAll(
    filters: {
      isActive?: boolean;
      role?: string;
    } = {},
  ): Promise<User[]> {
    const query: any = {};
    if (filters.isActive !== undefined) query.isActive = filters.isActive;
    if (filters.role) query.role = filters.role;

    return this.userModel
      .find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .exec();
  }

  // Find user by ID
  async findOne(id: string): Promise<User> {
    const user = await this.userModel.findById(id).select('-password').exec();
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  // Find user by email (includes password for authentication)
  async findByEmail(email: string, includePassword = false): Promise<User | null> {
    const query = this.userModel.findOne({ email });
    if (!includePassword) {
      query.select('-password');
    }
    return query.exec();
  }

  // Find user by email with password (for authentication)
  async findByEmailWithPassword(email: string): Promise<User | null> {
    return this.userModel.findOne({ email }).select('+password').exec();
  }

  // Update user
  async update(id: string, updateUserDto: UpdateUserDto): Promise<User> {
    const user = await this.userModel.findById(id);
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    // If updating email, check if it's already taken
    if (updateUserDto.email) {
      const existingUser = await this.userModel.findOne({
        email: updateUserDto.email,
        _id: { $ne: id },
      });
      if (existingUser) {
        throw new ConflictException(
          `Email ${updateUserDto.email} is already taken`,
        );
      }
    }

    // If updating password, hash it
    if (updateUserDto.password) {
      const saltRounds = this.configService.get<number>('bcrypt.saltRounds') || 10;
      updateUserDto.password = await bcrypt.hash(updateUserDto.password, saltRounds);
    }

    const updatedUser = await this.userModel
      .findByIdAndUpdate(id, updateUserDto, {
        new: true, // Return the updated document
        runValidators: true, // Run schema validators
      })
      .select('-password')
      .exec();

    if (!updatedUser) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }

    return updatedUser;
  }

  // Soft delete user (set isActive to false)
  async remove(id: string): Promise<User> {
    const user = await this.userModel.findByIdAndUpdate(
      id,
      { isActive: false },
      { new: true },
    );
    if (!user) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
    return user;
  }

  // Hard delete user (permanent removal)
  async hardDelete(id: string): Promise<void> {
    const result = await this.userModel.findByIdAndDelete(id).exec();
    if (!result) {
      throw new NotFoundException(`User with ID ${id} not found`);
    }
  }

  // Update last login timestamp
  async updateLastLogin(id: string): Promise<void> {
    await this.userModel.findByIdAndUpdate(id, {
      lastLoginAt: new Date(),
    });
  }

  // Validate user password
  async validatePassword(user: User, password: string): Promise<boolean> {
    // Ensure we have the hashed password
    const userWithPassword = await this.findByEmailWithPassword(user.email);
    if (!userWithPassword) return false;
    
    return bcrypt.compare(password, userWithPassword.password);
  }

  // Count users
  async countUsers(filter: any = {}): Promise<number> {
    return this.userModel.countDocuments(filter);
  }

  // Get user statistics (for dashboard)
  async getUserStats(): Promise<any> {
    const total = await this.userModel.countDocuments();
    const active = await this.userModel.countDocuments({ isActive: true });
    const roles = await this.userModel.aggregate([
      {
        $group: {
          _id: '$role',
          count: { $sum: 1 },
        },
      },
    ]);

    return {
      total,
      active,
      inactive: total - active,
      roles: roles.reduce((acc, r) => ({ ...acc, [r._id]: r.count }), {}),
    };
  }
}
