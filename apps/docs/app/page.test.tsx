import { expect, test } from "vitest";
import { render, screen } from "@testing-library/react";
import Page from "./page";

test("should render text correctly", () => {
  render(<Page />);

  expect(screen.getByText("apps/docs/app/page.tsx")).toBeDefined();
});
