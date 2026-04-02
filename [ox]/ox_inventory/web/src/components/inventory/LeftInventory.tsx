import InventoryGrid from './InventoryGrid';
import { useAppSelector } from '../../store';
import { selectLeftInventory } from '../../store/inventory';
import { InventoryTab } from './InventoryGrid';

interface LeftInventoryProps {
  activeTab?: InventoryTab;
  onTabChange?: (tab: InventoryTab) => void;
}

const LeftInventory: React.FC<LeftInventoryProps> = ({ activeTab, onTabChange }) => {
  const leftInventory = useAppSelector(selectLeftInventory);

  return <InventoryGrid inventory={leftInventory} activeTab={activeTab} onTabChange={onTabChange} />;
};

export default LeftInventory;