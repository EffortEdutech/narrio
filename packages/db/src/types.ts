export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[];

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          username: string | null;
          display_name: string | null;
          avatar_url: string | null;
          bio: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id: string;
          username?: string | null;
          display_name?: string | null;
          avatar_url?: string | null;
          bio?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["profiles"]["Insert"]>;
      };
      stories: {
        Row: {
          id: string;
          author_id: string;
          forked_from_story_id: string | null;
          title: string;
          slug: string;
          synopsis: string | null;
          cover_url: string | null;
          status: "draft" | "published" | "archived";
          visibility: "public" | "unlisted" | "private";
          allow_forks: boolean;
          main_branch_id: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          author_id: string;
          forked_from_story_id?: string | null;
          title: string;
          slug: string;
          synopsis?: string | null;
          cover_url?: string | null;
          status?: "draft" | "published" | "archived";
          visibility?: "public" | "unlisted" | "private";
          allow_forks?: boolean;
          main_branch_id?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["stories"]["Insert"]>;
      };
      story_branches: {
        Row: {
          id: string;
          story_id: string;
          parent_branch_id: string | null;
          created_by: string;
          name: string;
          slug: string;
          description: string | null;
          branch_type: "main" | "fork" | "alternate" | "experimental";
          status: "active" | "archived";
          visibility: "public" | "unlisted" | "private";
          forked_from_version_id: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          story_id: string;
          parent_branch_id?: string | null;
          created_by: string;
          name: string;
          slug: string;
          description?: string | null;
          branch_type?: "main" | "fork" | "alternate" | "experimental";
          status?: "active" | "archived";
          visibility?: "public" | "unlisted" | "private";
          forked_from_version_id?: string | null;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["story_branches"]["Insert"]>;
      };
      chapters: {
        Row: {
          id: string;
          story_id: string;
          branch_id: string;
          chapter_number: number;
          title: string;
          slug: string | null;
          summary: string | null;
          is_published: boolean;
          published_at: string | null;
          created_by: string;
          created_at: string;
          updated_at: string;
        };
        Insert: {
          id?: string;
          story_id: string;
          branch_id: string;
          chapter_number: number;
          title: string;
          slug?: string | null;
          summary?: string | null;
          is_published?: boolean;
          published_at?: string | null;
          created_by: string;
          created_at?: string;
          updated_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["chapters"]["Insert"]>;
      };
      chapter_versions: {
        Row: {
          id: string;
          chapter_id: string;
          version_number: number;
          title: string;
          excerpt: string | null;
          content_md: string;
          source: "human" | "ai" | "import";
          commit_message: string | null;
          is_current: boolean;
          created_by: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          chapter_id: string;
          version_number: number;
          title: string;
          excerpt?: string | null;
          content_md: string;
          source?: "human" | "ai" | "import";
          commit_message?: string | null;
          is_current?: boolean;
          created_by: string;
          created_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["chapter_versions"]["Insert"]>;
      };
      bookmarks: {
        Row: {
          id: string;
          user_id: string;
          chapter_id: string;
          tag: string;
          is_public: boolean;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          chapter_id: string;
          tag: string;
          is_public?: boolean;
          created_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["bookmarks"]["Insert"]>;
      };
      follows: {
        Row: {
          id: string;
          user_id: string;
          story_id: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          story_id: string;
          created_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["follows"]["Insert"]>;
      };
      likes: {
        Row: {
          id: string;
          user_id: string;
          chapter_version_id: string;
          created_at: string;
        };
        Insert: {
          id?: string;
          user_id: string;
          chapter_version_id: string;
          created_at?: string;
        };
        Update: Partial<Database["public"]["Tables"]["likes"]["Insert"]>;
      };
    };
  };
}
