import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import App from './App'

describe('App', () => {
  it('renders without crashing', () => {
    render(<App />)
    // Verwenden Sie einen Text der tatsächlich in Ihrer App existiert
    expect(screen.getByText(/react/i)).toBeInTheDocument()
  })

  it('has vite logo', () => {
    render(<App />)
    const viteLink = screen.getByRole('link', { name: /vite/i })
    expect(viteLink).toBeInTheDocument()
  })
})