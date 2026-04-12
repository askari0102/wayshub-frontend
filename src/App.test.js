import { render } from '@testing-library/react';
import App from './App';
import { AppContextProvider } from './context/AppContext'; // Sesuaikan path ini dengan letak AppContext kamu

test('renders app without crashing', () => {
  render(
    <AppContextProvider>
      <App />
    </AppContextProvider>
  );
});