% vector equality

function eq = vecEq(a,b,tol)
    eq = any([all([all(a + tol > b), all(a - tol < b)]), all([all(b + tol > a), all(b - tol < a)])]);
end