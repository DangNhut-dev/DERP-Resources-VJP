// components/inventory/backpack.ts
// Backpack types and helpers for NUI

export interface BackpackData {
  idbalo: string;
  level: number;
  label: string;
  stashName: string;
  slots: number;
  maxWeight: number;
  weight: number;
  items: Record<number, BackpackItem | null>;
}

export interface BackpackItem {
  name: string;
  label: string;
  weight: number;
  slot: number;
  count: number;
  description?: string;
  metadata?: Record<string, any>;
  stack?: boolean;
  close?: boolean;
  durability?: number;
}

export interface BackpackSwapData {
  fromSlot: number;
  toSlot: number;
  fromType: 'player' | 'backpack' | 'right';
  toType: 'player' | 'backpack' | 'right';
  count: number;
}

export interface BackpackDropData {
  fromSlot: number;
  count: number;
  coords: { x: number; y: number; z: number };
  instance?: any;
}