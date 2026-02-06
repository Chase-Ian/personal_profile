
export enum Screen {
  MAIN = 'MAIN',
  PROJECTS_DEDICATED = 'PROJECTS_DEDICATED',
  FRIENDS_LIST = 'FRIENDS_LIST',
  EDIT_PROFILE = 'EDIT_PROFILE',
  LOGIN = 'LOGIN'
}

export interface Profile {
  name: string;
  bio: string;
  email: string;
  skills: string[];
  hobbies: string[];
  profilePic: string;
}

export interface Project {
  id: string;
  title: string;
  description: string;
  imageUrl: string;
  category: string;
}

export interface Friend {
  id: string;
  name: string;
  socialUrl: string;
  platform: string;
  profilePic: string;
}
