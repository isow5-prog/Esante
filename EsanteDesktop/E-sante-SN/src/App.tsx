import { Toaster } from "@/components/ui/toaster";
import { Toaster as Sonner } from "@/components/ui/sonner";
import { TooltipProvider } from "@/components/ui/tooltip";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { BrowserRouter, Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Dashboard from "./pages/Dashboard";
import Home from "./pages/Home";
import QRGeneration from "./pages/QRGeneration";
import ValidateCard from "./pages/ValidateCard";
import AddRecord from "./pages/AddRecord";
import ConsultRecord from "./pages/ConsultRecord";
import NotFound from "./pages/NotFound";
import AddCenter from "./pages/AddCenter";
// Nouvelles pages Ministère
import MothersList from "./pages/MothersList";
import UserManagement from "./pages/UserManagement";
import Statistics from "./pages/Statistics";
import Messages from "./pages/Messages";

const queryClient = new QueryClient();

const App = () => (
  <QueryClientProvider client={queryClient}>
    <TooltipProvider>
      <Toaster />
      <Sonner />
      <BrowserRouter>
        <Routes>
          {/* Page de connexion */}
          <Route path="/" element={<Login />} />
          
          {/* Routes Ministère */}
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/qr-generation" element={<QRGeneration />} />
          <Route path="/mothers-list" element={<MothersList />} />
          <Route path="/users" element={<UserManagement />} />
          <Route path="/statistics" element={<Statistics />} />
          <Route path="/messages" element={<Messages />} />
          <Route path="/add-center" element={<AddCenter />} />
          
          {/* Routes Agent de Santé */}
          <Route path="/home" element={<Home />} />
          <Route path="/consult-record" element={<ConsultRecord />} />
          <Route path="/validate-card" element={<ValidateCard />} />
          <Route path="/add-record" element={<AddRecord />} />
          
          {/* Route 404 */}
          <Route path="*" element={<NotFound />} />
        </Routes>
      </BrowserRouter>
    </TooltipProvider>
  </QueryClientProvider>
);

export default App;
