
import { Project, Friend } from '../types';

// Initial Mock Data
let mockProjects: Project[] = [
  {
    id: '1',
    title: 'Nebula Dashboard',
    description: 'A React-based space weather monitoring system for deep-space missions.',
    imageUrl: 'https://picsum.photos/seed/nebula/800/400',
    category: 'Application'
  },
  {
    id: '2',
    title: 'Quantum Portal',
    description: 'Experimenting with retro-futuristic shaders and high-speed data visualizers.',
    imageUrl: 'https://picsum.photos/seed/portal/800/400',
    category: 'Graphics'
  },
  {
    id: '3',
    title: 'Starship OS',
    description: 'User interface concepts for the next generation of interplanetary vessels.',
    imageUrl: 'https://picsum.photos/seed/starship/800/400',
    category: 'UI/UX'
  }
];

let mockFriends: Friend[] = [
  {
    id: '1',
    name: 'Major Tom',
    socialUrl: 'https://twitter.com/majortom',
    platform: 'X',
    profilePic: 'https://picsum.photos/seed/tom/100/100'
  },
  {
    id: '2',
    name: 'Ziggy Stardust',
    socialUrl: 'https://github.com/ziggy',
    platform: 'GitHub',
    profilePic: 'https://picsum.photos/seed/ziggy/100/100'
  }
];

export const supabaseService = {
  getProjects: async (): Promise<Project[]> => {
    return new Promise((resolve) => {
      setTimeout(() => resolve([...mockProjects]), 500);
    });
  },
  
  getFriends: async (): Promise<Friend[]> => {
    return new Promise((resolve) => {
      setTimeout(() => resolve([...mockFriends]), 500);
    });
  },

  addFriend: async (friend: Omit<Friend, 'id'>): Promise<Friend> => {
    const newFriend = { ...friend, id: Math.random().toString(36).substr(2, 9) };
    mockFriends.push(newFriend);
    return newFriend;
  },

  deleteFriend: async (id: string): Promise<void> => {
    mockFriends = mockFriends.filter(f => f.id !== id);
  }
};
