import {
  MessageSquare,
  Send,
  Search,
  Calendar,
  Users,
  Clock,
  MoreVertical,
  Edit,
  Trash2,
  Eye,
  Plus,
  Bell,
  CheckCircle,
} from "lucide-react";
import { useState } from "react";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Textarea } from "@/components/ui/textarea";
import { Card } from "@/components/ui/card";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
  DialogFooter,
} from "@/components/ui/dialog";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs";
import Header from "@/components/Header";

// Données fictives pour le prototype
const mockMessages = [
  {
    id: 1,
    title: "Vaccination contre le paludisme",
    content:
      "Rappel important : La campagne de vaccination contre le paludisme débute le 1er décembre. Assurez-vous que vos enfants de moins de 5 ans soient vaccinés dans votre centre de santé le plus proche.",
    category: "vaccination",
    status: "published",
    target: "all",
    sentAt: "2025-11-25 10:30",
    views: 1250,
    created_at: "2025-11-25",
  },
  {
    id: 2,
    title: "Consultations prénatales gratuites",
    content:
      "Bonne nouvelle ! Les consultations prénatales sont désormais gratuites dans tous les centres de santé publics. Profitez de ce service pour assurer un suivi optimal de votre grossesse.",
    category: "prenatal",
    status: "published",
    target: "mothers",
    sentAt: "2025-11-20 14:00",
    views: 890,
    created_at: "2025-11-20",
  },
  {
    id: 3,
    title: "Prévention de la malnutrition",
    content:
      "Conseils nutritionnels : Une alimentation équilibrée est essentielle pour la santé de votre enfant. Privilégiez les fruits, légumes et protéines dans les repas quotidiens.",
    category: "nutrition",
    status: "draft",
    target: "all",
    sentAt: null,
    views: 0,
    created_at: "2025-11-28",
  },
  {
    id: 4,
    title: "Horaires d'ouverture pendant les fêtes",
    content:
      "Information : Pendant la période des fêtes, les centres de santé seront ouverts de 8h à 14h. Les urgences restent disponibles 24h/24.",
    category: "info",
    status: "scheduled",
    target: "all",
    sentAt: "2025-12-20 08:00",
    views: 0,
    created_at: "2025-11-27",
  },
];

const categories = [
  { value: "vaccination", label: "Vaccination", color: "bg-blue-500" },
  { value: "prenatal", label: "Prénatal", color: "bg-pink-500" },
  { value: "nutrition", label: "Nutrition", color: "bg-green-500" },
  { value: "info", label: "Information", color: "bg-amber-500" },
  { value: "urgence", label: "Urgence", color: "bg-red-500" },
];

const Messages = () => {
  const [searchTerm, setSearchTerm] = useState("");
  const [statusFilter, setStatusFilter] = useState("all");
  const [isDialogOpen, setIsDialogOpen] = useState(false);
  const [newMessage, setNewMessage] = useState({
    title: "",
    content: "",
    category: "",
    target: "all",
  });

  const filteredMessages = mockMessages.filter((message) => {
    const matchesSearch =
      message.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
      message.content.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === "all" || message.status === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const publishedCount = mockMessages.filter((m) => m.status === "published").length;
  const draftCount = mockMessages.filter((m) => m.status === "draft").length;
  const scheduledCount = mockMessages.filter((m) => m.status === "scheduled").length;
  const totalViews = mockMessages.reduce((sum, m) => sum + m.views, 0);

  const getCategoryInfo = (category: string) => {
    return categories.find((c) => c.value === category) || { label: category, color: "bg-gray-500" };
  };

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "published":
        return (
          <Badge className="bg-green-500/20 text-green-700 hover:bg-green-500/30">
            <CheckCircle className="w-3 h-3 mr-1" />
            Publié
          </Badge>
        );
      case "draft":
        return (
          <Badge variant="secondary" className="bg-gray-500/20 text-gray-700">
            <Edit className="w-3 h-3 mr-1" />
            Brouillon
          </Badge>
        );
      case "scheduled":
        return (
          <Badge className="bg-blue-500/20 text-blue-700 hover:bg-blue-500/30">
            <Clock className="w-3 h-3 mr-1" />
            Programmé
          </Badge>
        );
      default:
        return null;
    }
  };

  const handlePublish = () => {
    console.log("Publication:", newMessage);
    setIsDialogOpen(false);
    setNewMessage({ title: "", content: "", category: "", target: "all" });
  };

  return (
    <div className="min-h-screen bg-background">
      <Header />

      <main className="max-w-7xl mx-auto p-6">
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-bold text-foreground">Messages de Prévention</h1>
            <p className="text-muted-foreground mt-1">
              Communiquez avec les mères et les agents de santé
            </p>
          </div>
          <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
            <DialogTrigger asChild>
              <Button className="gap-2">
                <Plus className="w-4 h-4" />
                Nouveau message
              </Button>
            </DialogTrigger>
            <DialogContent className="max-w-2xl">
              <DialogHeader>
                <DialogTitle>Créer un message de prévention</DialogTitle>
              </DialogHeader>
              <div className="space-y-4 mt-4">
                <div className="space-y-2">
                  <Label htmlFor="title">Titre du message</Label>
                  <Input
                    id="title"
                    placeholder="Ex: Campagne de vaccination..."
                    value={newMessage.title}
                    onChange={(e) => setNewMessage({ ...newMessage, title: e.target.value })}
                  />
                </div>
                <div className="space-y-2">
                  <Label htmlFor="content">Contenu</Label>
                  <Textarea
                    id="content"
                    placeholder="Rédigez votre message ici..."
                    rows={5}
                    value={newMessage.content}
                    onChange={(e) => setNewMessage({ ...newMessage, content: e.target.value })}
                  />
                </div>
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label>Catégorie</Label>
                    <Select
                      value={newMessage.category}
                      onValueChange={(value) => setNewMessage({ ...newMessage, category: value })}
                    >
                      <SelectTrigger>
                        <SelectValue placeholder="Sélectionner une catégorie" />
                      </SelectTrigger>
                      <SelectContent>
                        {categories.map((cat) => (
                          <SelectItem key={cat.value} value={cat.value}>
                            <div className="flex items-center gap-2">
                              <div className={`w-3 h-3 rounded-full ${cat.color}`}></div>
                              {cat.label}
                            </div>
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                  </div>
                  <div className="space-y-2">
                    <Label>Destinataires</Label>
                    <Select
                      value={newMessage.target}
                      onValueChange={(value) => setNewMessage({ ...newMessage, target: value })}
                    >
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="all">Tous</SelectItem>
                        <SelectItem value="mothers">Mères uniquement</SelectItem>
                        <SelectItem value="agents">Agents de santé</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>
              </div>
              <DialogFooter className="mt-6">
                <Button variant="outline" onClick={() => setIsDialogOpen(false)}>
                  Enregistrer en brouillon
                </Button>
                <Button onClick={handlePublish} className="gap-2">
                  <Send className="w-4 h-4" />
                  Publier
                </Button>
              </DialogFooter>
            </DialogContent>
          </Dialog>
        </div>

        {/* Statistiques */}
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-8">
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-primary/10">
                <MessageSquare className="w-6 h-6 text-primary" />
              </div>
              <div>
                <p className="text-2xl font-bold">{mockMessages.length}</p>
                <p className="text-sm text-muted-foreground">Total messages</p>
              </div>
            </div>
          </Card>
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-green-500/10">
                <CheckCircle className="w-6 h-6 text-green-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{publishedCount}</p>
                <p className="text-sm text-muted-foreground">Publiés</p>
              </div>
            </div>
          </Card>
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-blue-500/10">
                <Clock className="w-6 h-6 text-blue-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{scheduledCount}</p>
                <p className="text-sm text-muted-foreground">Programmés</p>
              </div>
            </div>
          </Card>
          <Card className="p-4">
            <div className="flex items-center gap-3">
              <div className="p-2 rounded-lg bg-amber-500/10">
                <Eye className="w-6 h-6 text-amber-600" />
              </div>
              <div>
                <p className="text-2xl font-bold">{totalViews.toLocaleString()}</p>
                <p className="text-sm text-muted-foreground">Vues totales</p>
              </div>
            </div>
          </Card>
        </div>

        {/* Tabs et filtres */}
        <Tabs defaultValue="all" className="space-y-6">
          <div className="flex flex-col md:flex-row gap-4 items-start md:items-center justify-between">
            <TabsList>
              <TabsTrigger value="all">Tous</TabsTrigger>
              <TabsTrigger value="published">Publiés ({publishedCount})</TabsTrigger>
              <TabsTrigger value="draft">Brouillons ({draftCount})</TabsTrigger>
              <TabsTrigger value="scheduled">Programmés ({scheduledCount})</TabsTrigger>
            </TabsList>
            <div className="relative w-full md:w-80">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
              <Input
                placeholder="Rechercher un message..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pl-10"
              />
            </div>
          </div>

          <TabsContent value="all" className="space-y-4">
            {filteredMessages.map((message) => (
              <Card key={message.id} className="p-6 hover:shadow-md transition-shadow">
                <div className="flex items-start justify-between">
                  <div className="flex-1">
                    <div className="flex items-center gap-3 mb-2">
                      <div
                        className={`w-3 h-3 rounded-full ${
                          getCategoryInfo(message.category).color
                        }`}
                      ></div>
                      <span className="text-sm text-muted-foreground">
                        {getCategoryInfo(message.category).label}
                      </span>
                      {getStatusBadge(message.status)}
                    </div>
                    <h3 className="text-lg font-semibold mb-2">{message.title}</h3>
                    <p className="text-muted-foreground text-sm line-clamp-2">
                      {message.content}
                    </p>
                    <div className="flex items-center gap-6 mt-4 text-sm text-muted-foreground">
                      <div className="flex items-center gap-1">
                        <Users className="w-4 h-4" />
                        {message.target === "all"
                          ? "Tous"
                          : message.target === "mothers"
                          ? "Mères"
                          : "Agents"}
                      </div>
                      <div className="flex items-center gap-1">
                        <Calendar className="w-4 h-4" />
                        {message.sentAt || "Non publié"}
                      </div>
                      {message.views > 0 && (
                        <div className="flex items-center gap-1">
                          <Eye className="w-4 h-4" />
                          {message.views.toLocaleString()} vues
                        </div>
                      )}
                    </div>
                  </div>
                  <DropdownMenu>
                    <DropdownMenuTrigger asChild>
                      <Button variant="ghost" size="icon">
                        <MoreVertical className="w-4 h-4" />
                      </Button>
                    </DropdownMenuTrigger>
                    <DropdownMenuContent align="end">
                      <DropdownMenuItem>
                        <Eye className="w-4 h-4 mr-2" />
                        Voir
                      </DropdownMenuItem>
                      <DropdownMenuItem>
                        <Edit className="w-4 h-4 mr-2" />
                        Modifier
                      </DropdownMenuItem>
                      {message.status === "draft" && (
                        <DropdownMenuItem>
                          <Send className="w-4 h-4 mr-2" />
                          Publier
                        </DropdownMenuItem>
                      )}
                      <DropdownMenuItem className="text-destructive">
                        <Trash2 className="w-4 h-4 mr-2" />
                        Supprimer
                      </DropdownMenuItem>
                    </DropdownMenuContent>
                  </DropdownMenu>
                </div>
              </Card>
            ))}

            {filteredMessages.length === 0 && (
              <Card className="p-8">
                <div className="text-center">
                  <MessageSquare className="w-12 h-12 text-muted-foreground mx-auto mb-4" />
                  <p className="text-muted-foreground">Aucun message trouvé</p>
                </div>
              </Card>
            )}
          </TabsContent>

          <TabsContent value="published">
            <div className="space-y-4">
              {mockMessages
                .filter((m) => m.status === "published")
                .map((message) => (
                  <Card key={message.id} className="p-6">
                    <h3 className="font-semibold">{message.title}</h3>
                    <p className="text-sm text-muted-foreground mt-2">{message.content}</p>
                  </Card>
                ))}
            </div>
          </TabsContent>

          <TabsContent value="draft">
            <div className="space-y-4">
              {mockMessages
                .filter((m) => m.status === "draft")
                .map((message) => (
                  <Card key={message.id} className="p-6">
                    <h3 className="font-semibold">{message.title}</h3>
                    <p className="text-sm text-muted-foreground mt-2">{message.content}</p>
                  </Card>
                ))}
            </div>
          </TabsContent>

          <TabsContent value="scheduled">
            <div className="space-y-4">
              {mockMessages
                .filter((m) => m.status === "scheduled")
                .map((message) => (
                  <Card key={message.id} className="p-6">
                    <div className="flex items-center gap-2 mb-2">
                      <Bell className="w-4 h-4 text-blue-600" />
                      <span className="text-sm text-blue-600">
                        Programmé pour le {message.sentAt}
                      </span>
                    </div>
                    <h3 className="font-semibold">{message.title}</h3>
                    <p className="text-sm text-muted-foreground mt-2">{message.content}</p>
                  </Card>
                ))}
            </div>
          </TabsContent>
        </Tabs>
      </main>
    </div>
  );
};

export default Messages;

