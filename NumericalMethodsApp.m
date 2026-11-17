classdef NumericalMethodsApp < handle
    % NUMERICALMETHODSAPP
   %A simple MATLAB GUI for:
   % 1. Newton-Raphson method
   % 2. Secant method
   % 3. Fourth-order Runge-Kutta (RK4)
   %  Save as NumericalMethodsApp.m, then run:
   %   app = NumericalMethodsApp;

    properties
        UIFigure
        MethodDropDown
        FunctionField
        X0Field
        X1Field
        T0Field
        Y0Field
        TendField
        HField
        TolField
        MaxIterField
        CalculateButton
        OutputArea
    end

    methods
        function app = NumericalMethodsApp()
            app.UIFigure = uifigure( ...
                'Name', 'Numerical Methods Solver', ...
                'Position', [100 100 900 690]);

            titleLabel = uilabel(app.UIFigure, ...
                'Text', 'NUMERICAL METHODS SOLVER', ...
                'FontSize', 20, 'FontWeight', 'bold', ...
                'HorizontalAlignment', 'center', ...
                'Position', [200 645 500 30]);

            uilabel(app.UIFigure, 'Text', 'Choose method:', ...
                'Position', [35 600 130 25]);
            app.MethodDropDown = uidropdown(app.UIFigure, ...
                'Items', {'Newton-Raphson', 'Secant', 'Runge-Kutta 4 (RK4)'}, ...
                'Value', 'Newton-Raphson', ...
                'Position', [175 600 250 28]);

            uilabel(app.UIFigure, 'Text', ...
                'Function (use .*, ./ and .^ for powers):', ...
                'Position', [35 555 300 25]);
            app.FunctionField = uieditfield(app.UIFigure, 'text', ...
                'Value', 'x.^3 - x - 2', ...
                'Position', [350 555 500 28]);

            % Root-finding inputs
            uilabel(app.UIFigure, 'Text', 'Initial guess x0:', ...
                'Position', [35 510 130 25]);
            app.X0Field = uieditfield(app.UIFigure, 'numeric', ...
                'Value', 1.5, 'Position', [175 510 110 28]);

            uilabel(app.UIFigure, 'Text', 'Second guess x1 (Secant):', ...
                'Position', [320 510 180 25]);
            app.X1Field = uieditfield(app.UIFigure, 'numeric', ...
                'Value', 2, 'Position', [510 510 110 28]);

            % RK4 inputs
            uilabel(app.UIFigure, 'Text', 'Initial time t0:', ...
                'Position', [35 465 130 25]);
            app.T0Field = uieditfield(app.UIFigure, 'numeric', ...
                'Value', 0, 'Position', [175 465 110 28]);

            uilabel(app.UIFigure, 'Text', 'Initial value y0:', ...
                'Position', [320 465 150 25]);
            app.Y0Field = uieditfield(app.UIFigure, 'numeric', ...
                'Value', 1, 'Position', [510 465 110 28]);

            uilabel(app.UIFigure, 'Text', 'Final time:', ...
                'Position', [35 420 130 25]);
            app.TendField = uieditfield(app.UIFigure, 'numeric', ...
                'Value', 1, 'Position', [175 420 110 28]);

            uilabel(app.UIFigure, 'Text', 'Step size h:', ...
                'Position', [320 420 150 25]);
            app.HField = uieditfield(app.UIFigure, 'numeric', ...
                'Value', 0.1, 'Position', [510 420 110 28]);

            % Accuracy settings
            uilabel(app.UIFigure, 'Text', 'Tolerance:', ...
                'Position', [35 375 130 25]);
            app.TolField = uieditfield(app.UIFigure, 'numeric', ...
                'Value', 1e-6, 'Position', [175 375 110 28]);

            uilabel(app.UIFigure, 'Text', 'Maximum iterations:', ...
                'Position', [320 375 160 25]);
            app.MaxIterField = uieditfield(app.UIFigure, 'numeric', ...
                'Value', 50, 'Limits', [1 Inf], ...
                'RoundFractionalValues', 'on', ...
                'Position', [510 375 110 28]);

            app.CalculateButton = uibutton(app.UIFigure, 'push', ...
                'Text', 'CALCULATE', ...
                'FontWeight', 'bold', 'FontSize', 14, ...
                'Position', [350 325 200 38], ...
                'ButtonPushedFcn', @(src,event) app.calculate());

            uilabel(app.UIFigure, 'Text', 'Step-by-step solution:', ...
                'FontWeight', 'bold', 'Position', [35 290 250 25]);

            app.OutputArea = uitextarea(app.UIFigure, ...
                'Editable', 'off', 'FontName', 'Consolas', ...
                'FontSize', 12, ...
                'Position', [35 20 815 265], ...
                'Value', {'Select a method, enter the inputs, and click CALCULATE.'});

            % Short guidance below the title
            uilabel(app.UIFigure, ...
                'Text', ['For Newton/Secant enter f(x). For RK4 enter dy/dt = f(t,y), ' ...
                         'using t and y in the expression.'], ...
                'FontSize', 10, 'FontColor', [0.25 0.25 0.25], ...
                'Position', [35 620 815 20]);
        end

        function calculate(app)
            try
                method = app.MethodDropDown.Value;
                expr = strtrim(app.FunctionField.Value);
                if isempty(expr)
                    error('Please enter a mathematical function.');
                end

                tol = app.TolField.Value;
                maxIter = round(app.MaxIterField.Value);
                if ~isfinite(tol) || tol <= 0
                    error('Tolerance must be a positive number.');
                end
                if ~isfinite(maxIter) || maxIter < 1
                    error('Maximum iterations must be at least 1.');
                end

                switch method
                    case 'Newton-Raphson'
                        f = str2func(['@(x) ' expr]);
                        lines = app.newtonRaphson(f, app.X0Field.Value, tol, maxIter);
                    case 'Secant'
                        f = str2func(['@(x) ' expr]);
                        lines = app.secantMethod(f, app.X0Field.Value, ...
                            app.X1Field.Value, tol, maxIter);
                    case 'Runge-Kutta 4 (RK4)'
                        f = str2func(['@(t,y) ' expr]);
                        lines = app.rungeKutta4(f, app.T0Field.Value, ...
                            app.Y0Field.Value, app.TendField.Value, ...
                            app.HField.Value, maxIter);
                    otherwise
                        error('Please select a valid method.');
                end

                app.OutputArea.Value = lines;
            catch ME
                app.OutputArea.Value = {['ERROR: ' ME.message]};
            end
        end

        function lines = newtonRaphson(app, f, x, tol, maxIter) %#ok<INUSL>
            lines = {
                'NEWTON-RAPHSON METHOD'
                'Formula: x(n+1) = x(n) - f(x(n))/f''(x(n))'
                sprintf('Starting value x0 = %.10g', x)
                ' '
                'Iter       x(n)              f(x(n))           Approx. error'
                '----------------------------------------------------------------'
            };

            converged = false;
            for k = 1:maxIter
                fx = app.scalarValue(f(x), 'f(x)');
                delta = sqrt(eps) * max(1, abs(x));
                dfx = (app.scalarValue(f(x + delta), 'f(x+delta)') - ...
                       app.scalarValue(f(x - delta), 'f(x-delta)')) / (2*delta);

                if ~isfinite(dfx) || abs(dfx) < 1e-14
                    error('Derivative is zero or too small near x = %.10g.', x);
                end

                xNew = x - fx/dfx;
                err = abs(xNew - x);
                lines{end+1,1} = sprintf('%3d   %16.9g   %16.9g   %12.4g', ...
                    k, x, fx, err); %#ok<AGROW>

                if abs(app.scalarValue(f(xNew), 'f(x)')) <= tol || err <= tol
                    x = xNew;
                    converged = true;
                    break;
                end
                x = xNew;
            end

            lines{end+1,1} = ' ';
            lines{end+1,1} = sprintf('Approximate root = %.12g', x);
            lines{end+1,1} = sprintf('f(root) = %.5g', app.scalarValue(f(x), 'f(root)'));
            if converged
                lines{end+1,1} = 'Status: Converged.';
            else
                lines{end+1,1} = 'Status: Maximum iterations reached; check the result.';
            end
        end

        function lines = secantMethod(app, f, x0, x1, tol, maxIter) %#ok<INUSL>
            if x0 == x1
                error('The two initial guesses must be different.');
            end

            lines = {
                'SECANT METHOD'
                'Formula: x(n+1) = x(n) - f(x(n))*(x(n)-x(n-1))/(f(x(n))-f(x(n-1)))'
                sprintf('Starting values: x0 = %.10g, x1 = %.10g', x0, x1)
                ' '
                'Iter       x(n-1)           x(n)             x(n+1)          Error'
                '----------------------------------------------------------------------------'
            };

            converged = false;
            for k = 1:maxIter
                f0 = app.scalarValue(f(x0), 'f(x0)');
                f1 = app.scalarValue(f(x1), 'f(x1)');
                denominator = f1 - f0;

                if abs(denominator) < 1e-14
                    error('Secant denominator is zero or too small. Try different guesses.');
                end

                x2 = x1 - f1*(x1-x0)/denominator;
                err = abs(x2-x1);
                lines{end+1,1} = sprintf('%3d   %13.7g   %13.7g   %13.7g   %10.3g', ...
                    k, x0, x1, x2, err); %#ok<AGROW>

                if abs(app.scalarValue(f(x2), 'f(x)')) <= tol || err <= tol
                    x1 = x2;
                    converged = true;
                    break;
                end
                x0 = x1;
                x1 = x2;
            end

            lines{end+1,1} = ' ';
            lines{end+1,1} = sprintf('Approximate root = %.12g', x1);
            lines{end+1,1} = sprintf('f(root) = %.5g', app.scalarValue(f(x1), 'f(root)'));
            if converged
                lines{end+1,1} = 'Status: Converged.';
            else
                lines{end+1,1} = 'Status: Maximum iterations reached; check the result.';
            end
        end

        function lines = rungeKutta4(app, f, t, y, tEnd, h, maxSteps) %#ok<INUSL>
            if h == 0
                error('Step size h cannot be zero.');
            end
            if tEnd == t
                error('Final time must be different from initial time.');
            end
            if sign(h) ~= sign(tEnd-t)
                error('Step size h must point from initial time toward final time.');
            end

            lines = {
                'FOURTH-ORDER RUNGE-KUTTA METHOD (RK4)'
                'For dy/dt = f(t,y):'
                'k1 = h*f(t,y)'
                'k2 = h*f(t+h/2,y+k1/2)'
                'k3 = h*f(t+h/2,y+k2/2)'
                'k4 = h*f(t+h,y+k3)'
                'y(next) = y + (k1+2*k2+2*k3+k4)/6'
                ' '
                'Step       t              y              k1             k2             k3             k4'
                '------------------------------------------------------------------------------------------'
            };

            step = 0;
            while sign(tEnd-t)*(tEnd-t) > 1e-12
                if step >= maxSteps
                    error('Maximum number of RK4 steps reached. Increase the maximum steps.');
                end

                hi = sign(h) * min(abs(h), abs(tEnd-t));
                k1 = hi * app.scalarValue(f(t,y), 'f(t,y)');
                k2 = hi * app.scalarValue(f(t+hi/2,y+k1/2), 'f(t+h/2,y+k1/2)');
                k3 = hi * app.scalarValue(f(t+hi/2,y+k2/2), 'f(t+h/2,y+k2/2)');
                k4 = hi * app.scalarValue(f(t+hi,y+k3), 'f(t+h,y+k3)');

                yNew = y + (k1+2*k2+2*k3+k4)/6;
                tNew = t + hi;
                step = step + 1;

                lines{end+1,1} = sprintf('%3d   %11.6g   %13.7g   %11.4g   %11.4g   %11.4g   %11.4g', ...
                    step, t, y, k1, k2, k3, k4); %#ok<AGROW>

                t = tNew;
                y = yNew;
            end

            lines{end+1,1} = ' ';
            lines{end+1,1} = sprintf('Final time = %.10g', t);
            lines{end+1,1} = sprintf('Approximate solution y(%.10g) = %.12g', t, y);
        end

        function value = scalarValue(app, value, label) %#ok<INUSL>
            if ~isnumeric(value) || ~isscalar(value) || ~isreal(value) || ~isfinite(value)
                error('%s must evaluate to one finite real number.', label);
            end
        end
    end
end
