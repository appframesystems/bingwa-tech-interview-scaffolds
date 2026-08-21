import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, HydratedDocument, Types } from 'mongoose';
import { TaskStatus, TaskPriority } from '../../common/constants/enums';

export type TaskDocument = HydratedDocument<Task>;

@Schema({
  timestamps: true, // Automatically adds createdAt and updatedAt
  toJSON: {
    transform: (doc, ret: any) => {
      ret.id = ret._id; // Map _id to id
      delete ret._id;
      delete ret.__v;
      return ret;
    },
  },
})
export class Task extends Document {
  @Prop({
    required: true,
    trim: true,
    minlength: 1,
    maxlength: 100,
  })
  title: string;

  @Prop({
    trim: true,
    maxlength: 500,
    default: '',
  })
  description: string;

  @Prop({
    type: String,
    enum: TaskStatus,
    default: TaskStatus.TODO,
  })
  status: TaskStatus;

  @Prop({
    type: String,
    enum: TaskPriority,
    default: TaskPriority.MEDIUM,
  })
  priority: TaskPriority;

  @Prop({
    type: Date,
    default: null,
  })
  dueDate: Date;

  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    required: true,
  })
  userId: Types.ObjectId;

  @Prop({
    type: Date,
    default: null,
  })
  completedAt: Date;

  @Prop({
    type: Date,
    default: null,
  })
  deletedAt: Date;

  @Prop({
    default: false,
  })
  isArchived: boolean;
}

export const TaskSchema = SchemaFactory.createForClass(Task);

// Indexes for faster queries
TaskSchema.index({ userId: 1, status: 1 });
TaskSchema.index({ userId: 1, priority: 1 });
TaskSchema.index({ userId: 1, dueDate: 1 });
TaskSchema.index({ userId: 1, createdAt: -1 });
TaskSchema.index({ deletedAt: 1 }); // For soft delete queries
