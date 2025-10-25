import { useQuery } from '@tanstack/react-query';
import { supabase } from '@/integrations/supabase/client';
import { useAuth } from '@/contexts/AuthContext';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Folder, FolderOpen } from 'lucide-react';

const FoldersTab = () => {
  const { user } = useAuth();

  const { data: folders, isLoading } = useQuery({
    queryKey: ['folders', user?.id],
    queryFn: async () => {
      const { data, error } = await supabase
        .from('folders')
        .select(`
          *,
          folder_items(count)
        `)
        .eq('user_id', user?.id)
        .order('created_at', { ascending: false });

      if (error) throw error;
      return data;
    },
    enabled: !!user,
  });

  if (isLoading) {
    return <div className="text-center py-8">Memuat data...</div>;
  }

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold mb-2">Folder</h2>
        <p className="text-muted-foreground">
          Organisir bisnis ke dalam folder
        </p>
      </div>

      {!folders || folders.length === 0 ? (
        <Card className="p-8 text-center">
          <Folder className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
          <h3 className="text-lg font-semibold mb-2">Belum ada folder</h3>
          <p className="text-muted-foreground">
            Buat folder untuk mengorganisir bisnis Anda
          </p>
        </Card>
      ) : (
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
          {folders.map((folder) => (
            <Card key={folder.id} className="p-4 hover:shadow-md transition-shadow cursor-pointer">
              <div className="flex items-start gap-3">
                <FolderOpen
                  className="h-8 w-8 mt-1"
                  style={{ color: folder.color || '#3b82f6' }}
                />
                <div className="flex-1">
                  <h3 className="font-semibold mb-1">{folder.name}</h3>
                  {folder.description && (
                    <p className="text-sm text-muted-foreground mb-2">
                      {folder.description}
                    </p>
                  )}
                  <Badge variant="secondary">
                    {folder.folder_items?.[0]?.count || 0} bisnis
                  </Badge>
                </div>
              </div>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
};

export default FoldersTab;
