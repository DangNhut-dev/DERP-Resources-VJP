import { Button, createStyles } from '@mantine/core';
import { IconProp } from '@fortawesome/fontawesome-svg-core';
import LibIcon from '../../../../components/LibIcon';

interface Props {
  icon: IconProp;
  canClose?: boolean;
  iconSize: number;
  handleClick: () => void;
}

const useStyles = createStyles((theme, params: { canClose?: boolean }) => ({
  button: {
    borderRadius: 3,
    flex: '1 15%',
    alignSelf: 'stretch',
    height: 'auto',
    textAlign: 'center',
    justifyContent: 'center',
    padding: 2,
    background: 'linear-gradient(180deg, rgba(28,28,28,0.82) 0%, rgba(14,14,14,0.82) 100%)',
    border: '1px solid rgba(255,255,255,0.08)',
    borderTop: '1px solid rgba(255,255,255,0.14)',
    boxShadow: `
      inset 0 1px 0 rgba(255,255,255,0.05),
      inset 0 -2px 4px rgba(0,0,0,0.5),
      0 4px 8px rgba(0,0,0,0.5)
    `,
    transition: 'all 0.15s ease',
    '&:hover': {
      background: params.canClose === false
        ? 'linear-gradient(180deg, rgba(28,28,28,0.82) 0%, rgba(14,14,14,0.82) 100%)'
        : 'linear-gradient(180deg, rgba(31,42,42,0.88) 0%, rgba(17,26,26,0.88) 100%)',
      borderColor: params.canClose === false
        ? 'rgba(255,255,255,0.08)'
        : 'rgba(5,242,242,0.35)',
      boxShadow: params.canClose === false
        ? 'inset 0 1px 0 rgba(255,255,255,0.05), inset 0 -2px 4px rgba(0,0,0,0.5), 0 4px 8px rgba(0,0,0,0.5)'
        : 'inset 0 1px 0 rgba(5,242,242,0.08), inset 0 -2px 4px rgba(0,0,0,0.5), 0 4px 12px rgba(0,0,0,0.6), 0 0 8px rgba(5,242,242,0.1)',
    },
    '&:active': {
      boxShadow: 'inset 0 2px 4px rgba(0,0,0,0.6)',
    },
    '&:disabled': {
      background: 'linear-gradient(180deg, rgba(20,20,20,0.75) 0%, rgba(10,10,10,0.75) 100%)',
      borderColor: 'rgba(255,255,255,0.04)',
      boxShadow: 'none',
    },
  },
  label: {
    color: params.canClose === false ? 'rgba(255,255,255,0.2)' : '#FFFFFF',
  },
}));

const HeaderButton: React.FC<Props> = ({ icon, canClose, iconSize, handleClick }) => {
  const { classes } = useStyles({ canClose });

  return (
    <Button
      variant="default"
      className={classes.button}
      classNames={{ label: classes.label }}
      disabled={canClose === false}
      onClick={handleClick}
    >
      <LibIcon icon={icon} fontSize={iconSize} fixedWidth />
    </Button>
  );
};

export default HeaderButton;