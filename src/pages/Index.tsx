import { useState } from 'react';
import { useAuth } from '@/contexts/AuthContext';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Card } from '@/components/ui/card';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { MapPin, LogOut, Search, Star, Folder, Tag, FileText } from 'lucide-react';
import SearchTab from '@/components/tabs/SearchTab';
import FavoritesTab from '@/components/tabs/FavoritesTab';
import FoldersTab from '@/components/tabs/FoldersTab';
import NotesTab from '@/components/tabs/NotesTab';

const Index = () => {
  const { user, signOut } = useAuth();
  const [activeTab, setActiveTab] = useState('search');

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      <header className="bg-white shadow-sm border-b">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <MapPin className="h-8 w-8 text-primary" />
            <div>
              <h1 className="text-2xl font-bold text-foreground">GMaps Market Insight</h1>
              <p className="text-sm text-muted-foreground">Selamat datang, {user?.email}</p>
            </div>
          </div>
          <Button variant="outline" onClick={signOut}>
            <LogOut className="h-4 w-4 mr-2" />
            Logout
          </Button>
        </div>
      </header>

      <main className="container mx-auto px-4 py-8">
        <Card className="p-6">
          <Tabs value={activeTab} onValueChange={setActiveTab}>
            <TabsList className="grid w-full grid-cols-4 mb-6">
              <TabsTrigger value="search" className="flex items-center gap-2">
                <Search className="h-4 w-4" />
                <span className="hidden sm:inline">Pencarian</span>
              </TabsTrigger>
              <TabsTrigger value="favorites" className="flex items-center gap-2">
                <Star className="h-4 w-4" />
                <span className="hidden sm:inline">Favorit</span>
              </TabsTrigger>
              <TabsTrigger value="folders" className="flex items-center gap-2">
                <Folder className="h-4 w-4" />
                <span className="hidden sm:inline">Folder</span>
              </TabsTrigger>
              <TabsTrigger value="notes" className="flex items-center gap-2">
                <FileText className="h-4 w-4" />
                <span className="hidden sm:inline">Catatan</span>
              </TabsTrigger>
            </TabsList>

            <TabsContent value="search">
              <SearchTab />
            </TabsContent>

            <TabsContent value="favorites">
              <FavoritesTab />
            </TabsContent>

            <TabsContent value="folders">
              <FoldersTab />
            </TabsContent>

            <TabsContent value="notes">
              <NotesTab />
            </TabsContent>
          </Tabs>
        </Card>
      </main>
    </div>
  );
};

export default Index;
